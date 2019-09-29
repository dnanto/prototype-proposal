#!/usr/bin/env bash

blastdbcmd -db ../data/db -entry all -outfmt "%a %l" | \
	awk '$2 > 34000 { print $1; }' | \
	sort -b | \
	join -t $'\t' - ../data/date.tsv | \
	sort -k 2 | \
	tee date.tsv | \
	awk '$2 != "NA" { printf "s/^>%s/>%s_%s/\n", $1, $1, $2; }' > def.sed

cut -f 1 date.tsv | \
	blastdbcmd -db ../data/db -entry_batch - | \
	sed -f def.sed | \
	mafft --auto --adjustdirection --thread -1 - > msa-1.fna 2> msa-1.log

awk '$2 != "NA"' date.tsv | \
	blastdbcmd -db ../data/db -entry_batch - | \
	sed -f def.sed | \
	mafft --auto --adjustdirection --thread -1 - > msa-2.fna 2> msa-2.log

rm -rf phy-1.* && iqtree -s msa-1.fna -pre phy-1 -alrt 1000 -bb 1000 -bnni -nt AUTO
rm -rf phy-2.* && iqtree -s msa-2.fna -pre phy-2 -alrt 1000 -bb 1000 -bnni -nt AUTO
