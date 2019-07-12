for file in *.txt;
do
	sed -i s/,,//g $file
done
