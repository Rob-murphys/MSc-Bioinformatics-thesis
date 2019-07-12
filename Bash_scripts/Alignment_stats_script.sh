#calculating the relavent stats for each file
for filename in *.fa;
do
	function name {
	echo $filename | awk -F '.' '{print$1}'
	}
	echo "Stats calculation $filename file"
	bbmap/stats.sh in=$filename > $name.tsv
done


#excracting only the stats that I want from each output file of stats.sh
for file in *.tsv;
do	
	function name {
	echo $file | awk -F '.' '{print$1}'
	}
	echo "Extracting N50 and contig number for $file"
	awk 'FNR == 9 {print $5}' $file | awk -F '/' '{print$1}' > $(name)_N50.tsv
	awk 'FNR == 5 {print $5}' $file | awk -F '/' '{print$1}' > $(name)_NumContig.tsv
	sed  -i 's/$/\t$name/' $(name)_N50.tsv
	sed  -i 's/$/\t$name/' $(name)_NumContig.tsv
	
done	

#concatanating all the information into one file both with and without file names

cat *_NumContig.tsv > NumContig_output.tsv
cat *_N50.tsv > N50_output.tsv


