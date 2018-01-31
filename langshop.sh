#!/bin/bash
grep sent_id shopen-examples.conllu | perl -e 'while(<>){s/\r?\n$//; s-^.*/--; $h{$_}++} @k=sort{my $r=$h{$b}<=>$h{$a}; unless($r){$r=$a cmp $b} $r}(keys(%h)); foreach my $k (@k) {print("$k\t$h{$k}\n");}'
