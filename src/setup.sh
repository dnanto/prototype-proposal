#!/usr/bin/env bash

mkdir -p data && cd data || exit 1
query="txid714978[PORG] AND biomol_genomic[PROP] NOT gbdiv_pat[PROP] NOT gbdiv_syn[PROP]"
esearch -db nuccore -query "$query" | \
	efetch -db nuccore -format fasta | \
	makeblastdb -dbtype nucl -title db -parse_seqids -hash_index -out db -logfile db.log
