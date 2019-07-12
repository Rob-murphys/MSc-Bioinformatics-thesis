for file in *.fa;
do
	mv "$file" "${file/"#"/_}"
done