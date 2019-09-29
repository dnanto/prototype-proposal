#!/usr/bin/env bash

query="(txid714978[PORG] OR txid343463[PORG]) AND biomol_genomic[PROP] NOT gbdiv_pat[PROP] NOT gbdiv_syn[PROP]"
esearch -db nuccore -query "$query" | \
	efetch -db nuccore -format fasta | \
	makeblastdb -dbtype nucl -title db -parse_seqids -hash_index -out db -logfile db.log

blastdbcmd -db db -entry all -outfmt "%a" | \
	../src/eutil.py esummary - -params "retmode=json" | \
	tee meta.json | \
	jq -r ".result | del(.uids) | map([.accessionversion, .subtype, .subname] | @tsv) | .[]" | \
	../src/subtype.R - 2> /dev/null | \
	../src/lubridate.R - collection_date > meta.tsv 2> /dev/null

head -n 1 meta.tsv | tr '\t' '\n' | cat -n | grep collection_date | cut -f 1 | \
	xargs -I % cut -f 1,% meta.tsv | tail -n +2 | sort -b > date.tsv
