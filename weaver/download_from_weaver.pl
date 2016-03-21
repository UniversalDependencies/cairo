#!/usr/bin/env perl
# Downloads all on-line annotations of the Cairo Cicling Corpus.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use LWP::Simple;

my @languages = qw(ar bg bn ca cs da de el en es et eu ewo fa fi fil fr ga ha hi hr hu it ja ko lv mk mr ne nl no or pl pt rcf ro ru sk sl sr sv ta te tr ur vi yo zh);
# wget "http://weaver.nlplab.org/ud/ajax.cgi?action=downloadFile&collection=%2Fcicling2015%2F&document=ru&extension=txt&protocol=1" -O ru.txt
# wget "http://weaver.nlplab.org/ud/ajax.cgi?action=downloadFile&collection=%2Fcicling2015%2F&document=ru&extension=ann&protocol=1" -O ru.brat
my $baseurl = 'http://weaver.nlplab.org/ud/ajax.cgi?action=downloadFile&protocol=1&collection=%2Fcicling2015%2F';
foreach my $language (@languages)
{
    print STDERR ("$language\n");
    foreach my $extension ('txt', 'ann')
    {
        my $document = get($baseurl."&document=$language&extension=$extension");
        my $filename = "$language.$extension";
        open(FILE, ">$filename") or die("Cannot write $filename: $!");
        print FILE ($document);
        close(FILE);
        system("git add $filename");
    }
    system("perl brat2conllu.pl $language.txt $language.ann > $language.conllu");
    system("git add $language.conllu");
}
system("git commit -m 'Downloaded annotation from weaver.nlplab.org.'");
