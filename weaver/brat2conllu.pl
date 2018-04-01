#!/usr/bin/env perl
# Reads annotation in the Brat Standoff format. Writes CoNLL-U.
# Copyright © 2016, 2018 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL
# Documentation of the Brat Standoff format: http://brat.nlplab.org/standoff.html
# Documentation of the CoNLL-U format: http://universaldependencies.org/format.html
# We need both the txt and the ann file from Brat (example for Russian, 'ru'):
# wget "http://weaver.nlplab.org/ud/ajax.cgi?action=downloadFile&collection=%2Fcicling2015%2F&document=ru&extension=txt&protocol=1" -O ru.txt
# wget "http://weaver.nlplab.org/ud/ajax.cgi?action=downloadFile&collection=%2Fcicling2015%2F&document=ru&extension=ann&protocol=1" -O ru.brat
# perl brat2conllu.pl --sidprefix syntagrus- ru.txt ru.brat > ru.conllu

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;

my $sid_prefix = '';
GetOptions
(
    'sidprefix=s' => \$sid_prefix
);

# Minimize the output when run as a cron job.
my $quiet = 1;
my $txtfile = shift(@ARGV);
my $text;
my @sentences;
open(TXT, $txtfile) or die("Cannot read $txtfile: $!");
while(<TXT>)
{
    $text .= $_;
    push(@sentences, $_);
}
close(TXT);
my @chars = split(//, $text);
my %ahash;
my @tokens;
my %features;
my %relations;
my %srelations; # secondary relations for the DEPS column
while(<>)
{
    s/\r?\n$//;
    # Annotation ID and the rest.
    my $aid;
    my $ann;
    if(m/^(\S+)\t(.*)$/)
    {
        $aid = $1;
        $ann = $2;
    }
    $ahash{$aid} = $ann;
    # Text-bound annotation. In the case of Cairo Cicling Corpus, these are only tokens and their tags.
    # Example: T1 NOUN 743 749 письмо
    if($aid =~ m/^T/)
    {
        my ($tag, $c0, $c1, $form) = split(/\s+/, $ann);
        my %token =
        (
            'id'   => $aid,
            'c0'   => $c0, # index of the first character of the token (number of characters preceding it) in the txt file
            'c1'   => $c1, # index of the character after the token (it does not belong to the token)
            # We do not see spaces and line (sentence) breaks in the annotation file. We must consult the underlying text file.
            'form' => $form,
            'tag'  => $tag
        );
        push(@tokens, \%token);
    }
    # Attribute of another annotation. For us these are first of all features of tokens.
    # Example: A1 Mood T156 Ind
    elsif($aid =~ m/^A/)
    {
        my ($feature, $token, $value) = split(/\s+/, $ann);
        $features{$token}{$feature} = $value;
    }
    # Relation between two tokens.
    # Example: R1 nmod Arg1:T49 Arg2:T45
    elsif($aid =~ m/^R/)
    {
        my ($deprel, $parent, $child);
        $ann =~ s/^\s+//;
        $ann =~ s/\s+$//;
        if($ann =~ m/^(\S+)\s+Arg1:(T\d+)\s+Arg2:(T\d+)$/)
        {
            $deprel = $1;
            $parent = $2;
            $child  = $3;
            ###!!! We store additional parents of the same child as secondary dependencies.
            ###!!! But we cannot figure out which dependency is the primary one. And if we take the secondary instead, we may create a cycle.
            if(exists($relations{$child}))
            {
                my $p0 = $relations{$child}{parent};
                print STDERR ("WARNING: Multiple incoming edges to child $child: $p0 vs. $parent.\n") unless($quiet);
                push(@{$srelations{$child}},
                {
                    'parent' => $parent,
                    'child'  => $child,
                    'deprel' => $deprel
                });
            }
            else
            {
                $relations{$child} =
                {
                    'parent' => $parent,
                    'child'  => $child,
                    'deprel' => $deprel
                }
            }
        }
        else
        {
            print STDERR ("WARNING: Unexpected relation '$ann'\n") unless($quiet);
        }
    }
}
@tokens = sort {$a->{c0} <=> $b->{c0}} (@tokens);
# Find sentence breaks and assign sentence-internal numbers (IDs) to nodes.
# We must number all nodes before we can translate references from children to parents.
my %tid2iid;
my $i = 1;
for(my $j = 0; $j <= $#tokens; $j++)
{
    # A line break between tokens means sentence break for us.
    if($j > 0)
    {
        my $offset0 = $tokens[$j-1]->{c0};
        my $offset1 = $tokens[$j]->{c1}-1;
        if($offset1 >= $offset0)
        {
            my $interstring = join('', @chars[$offset0..$offset1]);
            if($interstring =~ m/\n/)
            {
                $tokens[$j-1]->{sentend} = 1;
                $i = 1;
            }
        }
    }
    $tokens[$j]->{iid} = $i;
    $tid2iid{$tokens[$j]->{id}} = $i;
    $i++;
}
print("\# sent_id = ${sidprefix}s1\n");
print("\# text = $sentences[0]");
my $isent = 0;
foreach my $token (@tokens)
{
    my $features = '_';
    if(exists($features{$token->{id}}))
    {
        my @fvpairs = sort {lc($a) cmp lc($b)} (map {"$_=$features{$token->{id}}{$_}"} (keys(%{$features{$token->{id}}})));
        $features = join('|', @fvpairs);
    }
    my $head = '0';
    my $deprel = '_';
    my $relation = $relations{$token->{id}};
    if(defined($relation))
    {
        $head = $tid2iid{$relation->{parent}};
        $deprel = $relation->{deprel};
    }
    my $deps = '_';
    if(scalar(@{$srelations{$token->{id}}})>0)
    {
        $deps = join('|', map {"$_->{head}:$_->{deprel}"} (sort {$a->{head} <=> $b->{head}} (map {{'head' => $tid2iid{$_->{parent}}, 'deprel' => $_->{deprel}}} (@{$srelations{$token->{id}}}))));
    }
    my $offset = "$token->{c0}-$token->{c1}";
    print($token->{iid}, "\t", $token->{form}, "\t_\t", $token->{tag}, "\t_\t", $features, "\t", $head, "\t", $deprel, "\t", $deps, "\tOffset=$offset\n", $token->{sentend} ? "\n" : '');
    if($token->{sentend})
    {
        $isent++;
        if($isent <= $#sentences)
        {
            my $sid = $isent + 1;
            print("\# sent_id = ${sidprefix}s$sid\n");
            print("\# text = $sentences[$isent]");
        }
    }
}
print("\n");
