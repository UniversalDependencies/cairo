# This is just to remember mz steps, especially the wc_conll + Perl command.
# This file cannot be used directly with make because '$' in the Perl line is not escaped.
# (And in any case, the output of the last command would make the output of the previous commands invisible.)
fake:
	git pull --no-edit
	python3 ../tools/validate.py --lang shopen shopen-examples.conllu
	wc_conll.pl shopen-examples.conllu ; (wc_conll.pl shopen-examples.conllu | perl -pe 'm/^(\d+) sentences, (\d+) tokens/; $_ = ($2/$1)." average tokens per sentence\n"')
	./langshop.sh | wc -l
	./langshop.sh | less

