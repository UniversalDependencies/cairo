wcc shopen-examples.conllu ; ( wcc shopen-examples.conllu | perl -pe 'm/(\d+) sentences, (\d+) tokens/; $_ = $2/$1." average tokens per sentence\n";' )
