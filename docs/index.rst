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

.. toctree::
   :maxdepth: 2
   :hidden:

   overview
   installation
   configuration
   usage
   contributing
   authors
   history

.. |Snakemake| image:: https://img.shields.io/badge/snakemake-≥3.13.3-brightgreen.svg
   :target: https://snakemake.bitbucket.io

.. |wercker status| image:: https://app.wercker.com/status/1a082864b6d5aded29f41c2e44387763/s/master
   :target: https://app.wercker.com/project/byKey/1a082864b6d5aded29f41c2e44387763
