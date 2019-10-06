The B-55’s

# Abstract

Human adenovirus B-55 (HAdV-B55) is a re-emergent pathogen that threatens dense populations.

# Introduction

The Adenoviridae family includes genera that infect a wide range of hosts and cell types. The Mastadenovirus genus includes species that infect mammalian hosts. They are globally distributed and are responsible for sporadic outbreaks in densely populated regions and close-living quarters. Symptoms range from acute respiratory disease to organ failure, depending on the viral species and host immune strength. Accordingly, individuals with developing or weakened immune systems account for most outbreak deaths.

# Methods

## Data

A Bash script coordinated the retrieval of nucleotide sequences and metadata. The Entrez Direct E-utilities scripts provided a command-line interface to query and retrieve data from the federated set of National Center for Biotechnology Information (NCBI) databases . The Bash script generated the following query to download the sequences from the Nucleotide database.

```sql
(txid714978[PORG] OR txid343463[PORG]) AND biomol_genomic[PROP] NOT gbdiv_pat[PROP] NOT gbdiv_syn[PROP]
```

The square brackets enclose keywords that corresponds to search fields. The fields immediately follow each value. The PORG and PROP fields correspond to primary organism and property respectively. The first two PORG terms limit the search to HAdV-55 and HAdV-11a respectively. The first PROP term sets the molecule type and the latter two exclude GenBank divisions (Romiti and Cooper, 2011). Specifically, these terms limit the search to genomic DNA while excluding patents and synthetic constructs respectively. The **esearch** command executed the query and the **efetch** commands retrieved the FASTA-formatted sequence data. The Bash script piped the results directly into the **makeblastdb** command to generate a BLAST database.

## Metadata
