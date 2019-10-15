# The B-55’s: I am livin’ on Channel B!

## Abstract

*Human adenovirus B-55* (HAdV-B55) is a re-emergent pathogen that threatens dense populations.

## Significance

Human adenovirus is a clinically relevant model organism with significant biotechnology applications. It has a global distribution, causing sporadic outbreaks. The virus threatens populations with close-living quarters, such as military barracks. Consequently, the U.S. military vaccinates recruits against types E4 and B7. Recent outbreaks of different types in civilian populations are on the rise.  B55 is no exception and originally rarely affected military populations. 

## Introduction

The *Adenoviridae* family includes genera that infect a wide range of hosts and cell types. The *Mastadenovirus* genus includes species that infect mammalian hosts. They are globally distributed, causing sporadic outbreaks in densely populated regions and close-living quarters. Carriers may expose others via aerosol or fecal-oral transmission, possibly asymptomatically (Lynch III and Kajon, 2016). Symptoms range from acute respiratory disease to organ failure, depending on the viral species and host immune strength (Lynch III and Kajon, 2016). Accordingly, individuals with developing or weakened immune systems account for most outbreak deaths.

### Biology

The Adenoviridae are class I linear double stranded DNA viruses (Baltimore, 1971). The nonenveloped icosahedral nucleocapsid consists of hexon and penton capsomers forming the faces and vertexes respectively. The coxsackie adenovirus receptor of the host cell recognizes the fiber knob while the penton RGD motif induces structural changes to gain entry (Pettersson, 2019).

### History

In 1953, an epidemic occurred at the Fort Leonard Wood U.S. Army installation in Missouri. A patient presented with pneumonia-like symptoms and provided a throat wash sample that contained the first viral isolate, initially called “adenoid degeneration agent” and later adenovirus (Hllleman and Werner, 1954; Rowe et al., 1953). Subsequent outbreaks resulted in the discovery of other types, including HAdV-B55. This is a re-emergent respiratory pathogen with a B14 genomic backbone and a recombinant hexon partially derived from B11 (Yang et al., 2009). A new typing scheme that includes genomic analysis corrected it’s previous misidentification as B11a due to limitations associated with serological assays with respect to recombination effects (Walsh et al., 2010). 

### Prior Work

…

### Proposal

…

## Methods

…

### Data

A Bash script coordinated the retrieval of nucleotide sequences, generating a local BLAST database. The Entrez Direct E-utilities scripts provided a command-line interface to query and retrieve data from the federated set of National Center for Biotechnology Information (NCBI) databases (Kans, 2019). The script generated the following query to download the sequences from the Nucleotide database.

```sql
(txid714978[PORG] OR txid343463[PORG]) AND biomol_genomic[PROP] NOT gbdiv_pat[PROP] NOT gbdiv_syn[PROP]
```

Each search value has an associated keyword field enclosed within square brackets. The PORG and PROP fields correspond to primary organism and property respectively. The first two PORG terms use NCBI Taxonomy identifiers to limit the search to HAdV-55 and HAdV-11a respectively. The first PROP term sets the molecule type while the next two exclude GenBank divisions (Romiti and Cooper, 2011). Specifically, these terms limit the search to genomic DNA while excluding patents and synthetic constructs respectively. The **esearch** and **efetch* programs executed the query and retrieved the FASTA-formatted sequence data respectively. The script piped the results directly into the **makeblastdb** program to generate a BLAST database.

### Metadata

The same Bash script also coordinated the retrieval and normalization of sequence metadata to create a database of “collection_date” values for subsequent molecular clock calibration and analysis. The script retrieved the set of sequence accessions via **blastdbcmd** and piped them into the **esummary** to download the JSON-formatted metadata from Nucleotide. The **jq** program executed the following query to transform the records into a tab-separated file.

```jq
.result | del(.uids) | map([.accessionversion, .subtype, .subname] | @tsv) | .[]
``` 

Each record contains a “subtype” and “subname” property. They are pipe-delimited string values that correspond to keys and values respectively. Together, the key-value pairs represent sequence metadata contained within the zeroth sequence feature of a GenBank file. An R script used **tidyverse** functions to split these property values and bind the resulting key-value pairs into new columns (Wickham, 2017). Another R script relied on the **lubridate** package to automatically convert the date field values into a consistent ISO-8601 format (Spinu et al., 2018). This series of commands generated a sorted tab-separated file, mapping accessions to collection dates.

### Sequence Extraction

The full genome extraction method involved a simple series of piped commands. The **blastdbcmd** program dumped a space-separated list of accession-length pairs. Next, **awk** selected accessions with lengths ≥34 kbp.

The gene extraction method was more involved, requiring a reference sequence. The **blastdbcmd** program retrieved the reference based on an accession and sequence coordinates. The **blastn** program used the reference to query the database using the *megablast* task, generating a list of subject accessions. The **blastdbcmd** program extracted the complete sequences for subsequent global-local alignment using **glsearch36**. This step guarantees complete alignment of the query to an optimal region on the subject. An **awk** script selected hits with sequence identity ≥90%.

For both methods, a series of piped **awk**, **sort**, **join** invocations generated **sed** command files for subsequent modification of the headers to include the dates based on the “collection_date” database.

### Alignment

The **mafft** program performed multiple sequence alignments (Katoh, 2002). MAFFT achieves performance gains via multithreading while maintaining accuracy via application of the Fast Fourier Transform on the sequence data to quickly identify homologous regions. Parameters included the “--auto” and “--adjustdirection” flags. The former automatically sets algorithm heuristics based on the sequence data and the latter automatically adjusts sequence direction for each entry if the reverse complement is optimal. The calling script redirected standard error into a log file to record alignment progress and heuristic selection. 

### Phylogeny

The IQ-TREE program inferred phylogenies (Nguyen et al., 2015). The program performed a series of likelihood tests to select the optimal number of threads and sequence evolution model based on the input data. The former compared the effect of adding additional threads on efficiency and the latter exploited the ModelFinder algorithm to estimate the optimal substitution model (Kalyaanamoorthy et al., 2017). Parameters included the -alrt and -bb flags to set the number of bootstrap replicates to 1,000 for the approximate likelihood ratio test of branches (Anisimova et al., 2011) and branch support (Hoang et al., 2018). The -bnni parameter also reduced the risk of model violations associated with ultrafast bootstrap testing via nearest neighbor interchange. The program automatically created a log file and exported the maximum likelihood tree in a variety of formats, including Newick.

### Molecular Clock

The TempEst program tests the strength of the strict molecular clock hypothesis for a given phylogeny (Rambaut et al., 2016). The program imports a tree file and parses the tip labels to extract the dates, plotting them against the root-to-tip patristic distance and fitting a regression line with an objective function that optimizes the correlation coefficient, R-squared value, or mean-squared residuals. This is an interactive tool that facilitates the identification of outliers that may result from incorrect collection dates, vaccine strains, or contaminated sequence data. An R script automated this process by plotting the model for the cross product of root-to-tip distance metrics and model objective functions. The script invoked the rtt and distRoot function of the ape (Paradis et al., 2019) and adephylo (Jombart et al., 2017) packages.

The BEAUti program is a graphical tool that outputs BEAST model parameters as XML files (Drummond and Bouckaert, 2015). The program imports a multiple alignment file and parses the sequence headers to extract the dates. Tip date sampling parameters included a uniform sampling distribution with an uncertainty of 10 years. Model testing from the IQ-TREE logs informed substitution model and base frequency parameter settings. Clock models included the strict clock, relaxed clock with lognormal distribution, and relaxed clock with exponential distribution (Drummond et al., 2006). Tree priors included the Constant Size (Kingman, 1982), Exponential Growth (Griffiths and Tavare, 1994), and Bayesian Skyline (Drummond et al., 2005) coalescent models. The MCMC parameters included a chain length of 108 with 10-3 sampling frequency. Marginal likelihood estimation included the path sampling (PS) / stepping-stone sampling method with 100 steps, chain length 106, sampling frequency 10-3, and Beta path step distribution (Baele et al., 2012, 2013).

BEAUti exported separate XML files representing the cross product of clock and coalescent models while maintaining all other settings and parameters constant. The **beast** program ran the MCMC simulation for each file. The **treeannotator** program subsequently calculated the maximum credibility clade using a 10% state burn-in and minimum posterior probability limit of 50%. A script submitted each job to a high-performance computing cluster queue, requesting 32 processors.

## Results

…

## Discussion

…

## References

*	Anisimova, M., Gil, M., Dufayard, J.-F., Dessimoz, C., and Gascuel, O. (2011). Survey of Branch Support Methods Demonstrates Accuracy, Power, and Robustness of Fast Likelihood-based Approximation Schemes. Syst. Biol. 60, 685–699.
*	Baele, G., Lemey, P., Bedford, T., Rambaut, A., Suchard, M.A., and Alekseyenko, A.V. (2012). Improving the Accuracy of Demographic and Molecular Clock Model Comparison While Accommodating Phylogenetic Uncertainty. Mol. Biol. Evol. 29, 2157–2167.
*	Baele, G., Li, W.L.S., Drummond, A.J., Suchard, M.A., and Lemey, P. (2013). Accurate Model Selection of Relaxed Molecular Clocks in Bayesian Phylogenetics. Mol. Biol. Evol. 30, 239–243.
*	Baltimore, D. (1971). Expression of animal virus genomes. Bacteriol. Rev. 35, 235–241.
*	Drummond, A.J., and Bouckaert, R.R. (2015). Bayesian Evolutionary Analysis with BEAST (Cambridge: Cambridge University Press).
*	Drummond, A.J., Rambaut, A., Shapiro, B., and Pybus, O.G. (2005). Bayesian Coalescent Inference of Past Population Dynamics from Molecular Sequences. Mol. Biol. Evol. 22, 1185–1192.
*	Drummond, A.J., Ho, S.Y.W., Phillips, M.J., and Rambaut, A. (2006). Relaxed Phylogenetics and Dating with Confidence. PLOS Biol. 4, e88.
*	Griffiths, R.C., and Tavare, S. (1994). Sampling Theory for Neutral Alleles in a Varying Environment. Philos. Trans. Biol. Sci. 344, 403–410.
*	Hllleman, M.R., and Werner, J.H. (1954). Recovery of New Agent from Patients with Acute Respiratory Illness. Proc. Soc. Exp. Biol. Med. 85, 183–188.
*	Hoang, D.T., Chernomor, O., von Haeseler, A., Minh, B.Q., and Vinh, L.S. (2018). UFBoot2: Improving the Ultrafast Bootstrap Approximation. Mol. Biol. Evol. 35, 518–522.
*	Jombart, T., Dray, S., and Bilgrau, A.E. (2017). adephylo: Exploratory Analyses for the Phylogenetic Comparative Method.
*	Kalyaanamoorthy, S., Minh, B.Q., Wong, T.K.F., von Haeseler, A., and Jermiin, L.S. (2017). ModelFinder: fast model selection for accurate phylogenetic estimates. Nat. Methods 14, 587–589.
*	Kans, J. (2019). Entrez Direct: E-utilities on the UNIX Command Line (National Center for Biotechnology Information (US)).
*	Katoh, K. (2002). MAFFT: a novel method for rapid multiple sequence alignment based on fast Fourier transform. Nucleic Acids Res. 30, 3059–3066.
*	Kingman, J.F.C. (1982). The coalescent. Stoch. Process. Their Appl. 13, 235–248.
*	Lynch III, J.P., and Kajon, A.E. (2016). Adenovirus: Epidemiology, Global Spread of Novel Serotypes, and Advances in Treatment and Prevention. Semin. Respir. Crit. Care Med. 37, 586–602.
*	Nguyen, L.-T., Schmidt, H.A., von Haeseler, A., and Minh, B.Q. (2015). IQ-TREE: A Fast and Effective Stochastic Algorithm for Estimating Maximum-Likelihood Phylogenies. Mol. Biol. Evol. 32, 268–274.
*	Paradis, E., Blomberg, S., Bolker, B., Brown, J., Claude, J., Cuong, H.S., Desper, R., Didier, G., Durand, B., Dutheil, J., et al. (2019). ape: Analyses of Phylogenetics and Evolution.
*	Pettersson, U. (2019). Encounters with adenovirus. Ups. J. Med. Sci. 1–11.
*	Rambaut, A., Lam, T.T., Max Carvalho, L., and Pybus, O.G. (2016). Exploring the temporal structure of heterochronous sequences using TempEst (formerly Path-O-Gen). Virus Evol. 2.
*	Romiti, M., and Cooper, P. (2011). Search Field Descriptions for Sequence Database (National Center for Biotechnology Information (US)).
*	Rowe, W.P., Huebner, R.J., Gilmore, L.K., Parrott, R.H., and Ward, T.G. (1953). Isolation of a Cytopathogenic Agent from Human Adenoids Undergoing Spontaneous Degeneration in Tissue Culture. Proc. Soc. Exp. Biol. Med. 84, 570–573.
*	Spinu, V., Grolemund, G., and Wickham, H. (2018). lubridate: Make Dealing with Dates a Little Easier.
*	Walsh, M.P., Seto, J., Jones, M.S., Chodosh, J., Xu, W., and Seto, D. (2010). Computational Analysis Identifies Human Adenovirus Type 55 as a Re-Emergent Acute Respiratory Disease Pathogen. J. Clin. Microbiol. 48, 991–993.
*	Wickham, H. (2017). tidyverse: Easily Install and Load the “Tidyverse.”
*	Yang, Z., Zhu, Z., Tang, L., Wang, L., Tan, X., Yu, P., Zhang, Y., Tian, X., Wang, J., Zhang, Y., et al. (2009). Genomic Analyses of Recombinant Adenovirus Type 11a in China. J. Clin. Microbiol. 47, 3082–3090.

