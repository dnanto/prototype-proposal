#!/usr/bin/env bash
cat seed.tsv | tr '\t' ' ' | while read -r line; do echo beast -seed "${line##* }" "${line% *}.xml" | qsub -V -d "$(pwd)" -N "${line% *}" -l nodes=1:ppn=32,walltime=48:00:00; done
