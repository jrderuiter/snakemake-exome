Snakemake-exome
===============

|Snakemake| |wercker status|

Snakemake-exome is a snakemake workflow that generates alignments from exome
sequencing data (or similar targeted DNA-sequencing data). The workflow is
designed to handle paired-end (and optionally multi-lane) sequencing data.
Processing of patient-derived xenograft (PDX) samples is also supported, by
using disambiguate to separate graft/host sequence reads.

If you use this workflow in a paper, don't forget to give credits
to the authors by citing the URL of this repository and, if available, its
DOI (see above).

.. |Snakemake| image:: https://img.shields.io/badge/snakemake-≥3.13.3-brightgreen.svg
   :target: https://snakemake.bitbucket.io

.. |wercker status| image:: https://app.wercker.com/status/1a082864b6d5aded29f41c2e44387763/s/master
   :target: https://app.wercker.com/project/byKey/1a082864b6d5aded29f41c2e44387763

Overview
--------

The standard (non-PDX) workflow essentially performs the following steps:

* The input reads are trimmed to remove adapters and/or poor quality base calls
  using cutadapt.
* The trimmed reads are aligned to the reference genome using bwa mem.
* The alignments are sorted and indexed using samtools.
* Bam files from multiple lanes are merged using samtools merge.
* Picard MarkDuplicates is used to remove optical/PCR duplicates.
* The final alignments are indexed using samtools index.

QC statistics are generated using fastqc, samtools stats and picard
CollectHSMetrics (to assess bait coverage). The stats are summarized into a
single report using multiqc.

This results in the following dependency graph:

.. image:: https://jrderuiter.github.io/snakemake-exome/_images/dag.svg

The PDX workflow is a slightly modified version of the standard workflow, which
aligns the reads to two reference genome (the host and graft reference genomes)
and uses disambiguate_ to remove sequences originating from the host organism.
See the docs_ for more details.

Documentation
-------------

Documentation is available at `jrderuiter.github.io/snakemake-exome`_.

License
-------

This software is released under the MIT license.

.. _jrderuiter.github.io/snakemake-exome: http://jrderuiter.github.io/snakemake-exome
.. _disambiguate: https://github.com/AstraZeneca-NGS/disambiguate
.. _docs: http://jrderuiter.github.io/snakemake-exome
