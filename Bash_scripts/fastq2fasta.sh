for file in *.fastq.gz;
do
	tag="${file%_*}"".fasta.gz"
	sed -n '1~4s/^@/>/p;2~4p' $file > $tag;
done