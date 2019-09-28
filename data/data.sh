#!/usr/bin/env bash

query="txid714978[PORG] AND biomol_genomic[PROP] NOT gbdiv_pat[PROP] NOT gbdiv_syn[PROP]"
esearch -db nuccore -query "$query" | \
	efetch -db nuccore -format fasta | \
	makeblastdb -dbtype nucl -title db -parse_seqids -hash_index -out db -logfile db.log

blastdbcmd -db db -entry all -outfmt "%a" | \
	../src/eutil.py esummary - -params "retmode=json" | \
	tee db.json | \
	jq -r ".result | del(.uids) | map([.accessionversion, .subtype, .subname] | @tsv) | .[]" | \
	../src/subtype.R - 2> /dev/null | \
	../src/lubridate.R - collection_date > db.tsv 2> /dev/null
