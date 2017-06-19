# Snakemake workflow: exome

[![Snakemake](https://img.shields.io/badge/snakemake-≥3.12.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![wercker status](https://app.wercker.com/status/1a082864b6d5aded29f41c2e44387763/s/master "wercker status")](https://app.wercker.com/project/byKey/1a082864b6d5aded29f41c2e44387763)

This is a Snakemake workflow for generating variant calls from exome sequencing
data (or similar targeted DNA-sequencing data). The workflow is designed to
handle paired-end (and optionally multi-lane) sequencing data.

The workflow essentially performs the following steps:

* The input reads are trimmed to remove adapters and/or poor quality base calls
  using cutadapt.
* The trimmed reads are aligned to the reference genome using bwa mem.
* The alignments are sorted using picard SortSam and indexed using samtools.
* Bam files from multiple lanes are merged using picard MergeSamFiles.
* Picard MarkDuplicates is used to remove optical/PCR duplicates.
* Variant calls are generated using freebayes.

QC statistics are generated using fastqc, samtools stats and picard
CollectHSMetrics (to assess bait coverage). The stats are summarized into a
single report using multiqc.

**Note that this workflow is still under active development.**

## Usage

### Step 1: Install workflow

If you simply want to use this workflow, download and extract the
[latest release](https://github.com/jrderuiter/snakemake-exome/releases).
If you intend to modify and further develop this workflow, fork this
repository. Please consider providing any generally applicable modifications
via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits
to the authors by citing the URL of this repository and, if available, its
DOI (see above).

### Step 2: Install dependencies

To be able to run the workflow, you need to have snakemake and pandas
installed. The various tools (e.g. bwa, samtools) also need to be installed
or can be managed via snakemake using conda (with the --use-conda flag).

### Step 3: Configure workflow

Configure the workflow according to your needs by editing the files
`config.yaml` and `samples.tsv`. Note that fastq file paths can be specified
as local file paths or remote http-based urls (other options can be added
on request).

### Step 4: Execute workflow

Test your configuration by performing a dry-run using

    snakemake -n

Execute the workflow locally via

    snakemake --cores $N

using `$N` cores or run it in a cluster environment using

    snakemake --cluster qsub --jobs 100

or

    snakemake --drmaa --jobs 100

The workflow can be executed in a different directory using

    snakemake --directory ~/scratch/exome

Note that this directory should contain the appropriate sample and config files.

See the [Snakemake documentation](https://snakemake.readthedocs.io) for
further details.

## Authors

* Julian de Ruiter (@jrderuiter)
