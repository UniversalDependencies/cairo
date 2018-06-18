#!/usr/bin/env perl
# Extracts from shopen-examples.conllu sentences in one language.
# Copyright © 2018 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: perl extract_language.pl LANGCODE < INPUT.conllu\n");
    # And we may also want to remove the comments that introduce the language.
    # perl extract_language.pl wbp < shopen-examples.conllu | perl -pe "$_='' if(m/^\# Warlpiri/)" > wbp.conllu
}

my $wanted_lcode = shift(@ARGV);
if(!defined($wanted_lcode))
{
    usage();
    die('Missing language code');
}

my @sentence = ();
my $lcode;
while(<>)
{
    # Find language code and remove it from the sentence id.
    if(s/^(\#\s*sent_id\s*=\s*\S+)\/(\S+)/$1/)
    {
        $lcode = $2;
    }
    push(@sentence, $_);
    if(m/^\s*$/)
    {
        if(defined($lcode) && $lcode eq $wanted_lcode)
        {
            print(join('', @sentence));
        }
        @sentence = ();
        $lcode = undef;
    }
}
