#!/usr/bin/env perl
# Counts the words in the individual translations of the Cairo Cicling Corpus.
# Copyright © 2021 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Read translations.txt from STDIN.
while(<>)
{
    s/\r?\n$//;
    if(m/^\[(.+?)\]/)
    {
        # Take the whole line as "lcode". We actually want separate entries where multiple people provided translations in the same language.
        $lcode = $_;
        push(@lcodes, $lcode);
    }
    elsif(!m/^\s*$/)
    {
        # Tokenize punctuation.
        s/(\pP)/ $1 /;
        s/^\s+//;
        s/\s+$//;
        my @words = split(/\s+/);
        $nsent{$lcode}++;
        $nword{$lcode} += scalar(@words);
    }
}
foreach my $lcode (@lcodes)
{
    printf("%2d sentences, %3d words, language %s\n", $nsent{$lcode}, $nword{$lcode}, $lcode);
}
