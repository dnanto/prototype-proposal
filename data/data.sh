#!/usr/bin/env bash

query="txid10509[Organism:exp] AND biomol_genomic[PROP] NOT gbdiv_pat[PROP] NOT gbdiv_syn[PROP]"
esearch -db nuccore -query "$query" | \
	efetch -format uid | \
	../src/eutil.py esummary - -post-size 500 -params retmode=json | \
	tee summary.json | \
	{
		printf "AccessionVersion\ttaxid\tSubType\tSubName\n"
		jq -r '.result | del(.uids) | map([.accessionversion, .taxid, .subtype, .subname] | @tsv) | .[]'
	} | \
	../src/subtype.R - 2> /dev/null | \
	../src/lubridate.R - collection_date > meta.tsv 2> /dev/null

awk 'NR > 1 { print $1, $2; }' meta.tsv | sort -b > taxid.ssv

awk 'NR > 1 { print $1; }' meta.tsv | \
	epost -db nuccore | \
	efetch -format fasta | \
	makeblastdb -dbtype nucl -title db -parse_seqids -hash_index -out db -logfile db.log -taxid_map taxid.ssv -blastdb_version 5

head -n 1 meta.tsv | tr '\t' '\n' | cat -n | grep collection_date | cut -f 1 | \
	xargs -I % cut -f 1,% meta.tsv | tail -n +2 | sort -b > date.tsv
