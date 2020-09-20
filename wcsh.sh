#!/bin/bash
wc_conll.pl shopen-examples.conllu ; ( wc_conll.pl shopen-examples.conllu | perl -pe 'm/(\d+) sentences, (\d+) tokens/; $_ = $2/$1." average tokens per sentence\n";' )
