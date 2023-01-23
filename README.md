# rrbs

RRBS and OxRRBS pipeline



Quick view: [download pipe](#quick) , make sure you have a correct sample list file, adapt [config yaml file](#quickyaml), then [run it](#quickrun)



Table of content

0.  [ Preliminary ](#quick)
1.  [Introduction and description  ](#intro)
2.  [copyFile  ](#copyFile)
3.  [gz  ](#gz)
4.  [fastqc  ](#fastqc)
5.  [TrimmGalore  ](#Trimm)
6.  [Bismark  ](#Bismark)
7.  [methylation_extractor  ](#methextr)
8.  [Bismark2report  ](#globQCreport)
9.  [Get Matrix  ](#matrix)


<a name="quick"></a>

## 0. Preliminary

## Download the pipeline in your project
The CIT pipelines are intended to be copied in the _03_Metadata_ directory

There are two ways of acessing the pipeline to process the data of a given project depending on whether you intend to only apply the pipeline or whether you might modify it and update the original repository with your improved version of it.

For the ***user only*** download:

```sh

mkdir -p 03_Metadata/rrbs
git archive --remote=git@gitlab.ligue-cancer.net:pipelines/rrbs.git v0.1 -o pipe.tar && tar -C 03_Metadata/pipe -xvf  pipe.tar

```

For the ***maybe develop and update*** download:

```sh
cd 03_Metadata
git clone https://gitlab.ligue-cancer.net/pipelines/rrbs.git

```



### Prep Sample list

```
sample1
sample2
sample3
...
```



<a name="quickyaml"></a>

### Parameters: Yaml


_Project specific variables_
* `rawdir:` path to initial stored data (ex `/datacit/01_PROJECTS/CIT_PROJECTS_HS/HS8_RAML_Penard-Lacronique/Data/Experiment_data/DNAmet_seq/01_Raw_files`)
* `newdir:` path to processing directory, usually on datacompute  (ex. `/datacompute/project1 `)
* `samplelist:` path to file with sample list (ex. `/datacit/01_PROJECTS/CIT_PROJECTS_HS/HS8_RAML_Penard-Lacronique/Data/Experiment_data/DNAmet_seq/03_Metadata/samplelist.txt`)
* `mval:` option 1 to compute mvalues matrix, 0 otherwise
* `betavalue:` option 1 to compute betavalues matrix, 0 otherwise
* `mincov:` minimum coverage of bases included in methylation matrix 

_Reference variables_
* `refgenome:` path to reference [preprocessed  ](#preprocess) genome directory (ex. `/datacit/01_PROJECTS/CIT_PROJECTS_HS/HS8_RAML_Penard-Lacronique/Data/Experiment_data/DNAmet_seq/03_Metadata/genomeref`)


<a name="quickrun"></a>

### Quick  start

After downlading in the 03_metadata, getting a samplelist and modifying yaml, Go to your work directory (usually `/Datacompute/directory`).


```sh
# from root of data dir
/usr/local/bin/snakemake  -s <project_path/Data/Experiment_data>/03_Metadata/rnaseq/snakes/rrbs_trimm.snake --configfile 03_Metadata/my.yaml --cores 208 --cluster /datacit/11_INFORMATIQUE/slurm_files/slurm_scheduler.py --cluster-config /datacit/11_INFORMATIQUE/slurm_files/slurm.json
```



<a name="intro"></a>

## 1. Introduction and description

This pipeline is for the processing of raw RRBS or OxRRBS data.

Input is compressed FASTQ (.fastq.gz) of raw sequences and output is multiple and includes:
QC files
trimming report
alignment report
methylation statistics
methylation calls

<a name="preprocess"></a>
# 1.a Reference genome preprocessing

In order to use a different genome/version, gather any fasta files of reference in a directory and perform:

```sh
bismark_genome_preparation --path_to_aligner /usr/local/bin/bowtie2 /path/to/genome_directory
```
The reference preprocessed genome is store in the same directory


<a name="step1"></a>
## 2. copyFile

Necessary first step, copies data to processing storage.

Starts with compressed FASTQ input on NAS storage and outputs files on /datacompute partition.


_troubleshoot_
* Not enough system disk space on /datacompute

<a name="gz"></a>
## 3. gz

Starts with compressed FASTQ files input, uncompressed it.


<a name="varscan"></a>
## 4. fastqc


Starts with FASTQ input, outputs a quality control report consisting of a number of different modules, each one of which will help to identify a different potential type of problem in your data.

<a name="Trimm"></a>
## 5. TrimGalore

TrimGalore, performs a trimming step specific to bisulfite sequencing with restriction enzyme. 
Considering both base quality and specifity of restrictiion enzyme.

<a name="Bismark"></a>
## 6. Bismark

Performs alignement of bisulfite treated reads.


<a name="methextr"></a>
## 7. Methylation extractor 

Extracts methylation status at base level.


<a name="GlobQCreport"></a>
## 8. Bismark2report

Reports quality of performed alignment.


<a name="matrix"></a>
## 9. Get matrix

Compute methylation matrix for all samples, Mvalues and Betavalues matrix can be processed or not depending on yaml arguments : `mval:` and `betavalue:`. 
Minimum coverage is defined by `mincov:`.


