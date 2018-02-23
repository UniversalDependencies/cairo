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
    push(@sentence, $_);
    if(m/^\#\s*sent_id\s*=\s*\S+\/(\S+)/)
    {
        $lcode = $1;
    }
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
