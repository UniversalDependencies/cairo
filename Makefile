# This is just to remember my steps, especially the wc_conll + Perl command.
# This file cannot be used directly with make because '$' in the Perl line is not escaped.
# (And in any case, the output of the last command would make the output of the previous commands invisible.)
shopen:
	git pull --no-edit
	python3 ../tools/validate.py --lang shopen shopen-examples.conllu
	# See also the wcsh.sh script in this folder.
	wc_conll.pl shopen-examples.conllu ; (wc_conll.pl shopen-examples.conllu | perl -pe 'm/^(\d+) sentences, (\d+) tokens/; $_ = ($2/$1)." average tokens per sentence\n"')
	./langshop.sh | wc -l
	./langshop.sh | less

# The file translations.conllu seems to be just a result of simple conversion assuming that translations.txt is already tokenized.
# (The result includes the language + author headers, not even separating punctuation there.)
