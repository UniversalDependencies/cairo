#!/usr/bin/env perl
# Surrounds every word with a character that should make the browsers correctly work around boundary between LTR and RTL text.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my @words;
while(<>)
{
    chomp();
    # 721   02D1   L   MODIFIER LETTER HALF TRIANGULAR COLON
    # Version 1: one sentence per line.
    my $result;
    if(0)
    {
        @words = map {"\x{02D1}".$_."\x{02D1}"} (split(/\s+/, $_));
        $result = join(' ', @words);
    }
    # Version 2: one word per line.
    elsif(0)
    {
        # Empty line separates sentences.
        if(m/^\s*$/)
        {
            print(join(' ', @words), "\n");
            splice(@words);
        }
        else
        {
            # Another hack we need for Brat is reordering tokens right-to-left, so use unshift() instead of push().
            unshift(@words, "\x{02D1}".$_."\x{02D1}");
        }
    }
    # Version 3: one word per line, romanized
    else
    {
        # Empty line separates sentences.
        if(m/^\s*$/)
        {
            print(join(' ', @words), "\n");
            splice(@words);
        }
        else
        {
            # Just join words, no right-to-left tricks.
            push(@words, $_);
        }
    }
}
