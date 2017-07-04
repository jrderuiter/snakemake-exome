Configuration
=============

The pipeline is configured using two config files, ``samples.tsv`` and
``config.yaml``. The ``samples.tsv`` file defines the input samples,
together with the paths to the respective source files. The ``config.yaml``
file provides detailed configuration options for the different
steps of the pipeline.

Sample definition
-----------------

The sample definition file is a tab-separated file that lists the samples
that are to be processed by the pipeline. Each row represents a single set of
(paired-end) fastq files for a given sample on a given lane. As such, samples
that have been sequenced on multiple lanes with typically span multiple rows
that share the same sample ID.

For example, a single sample sequenced over two lanes would be described
as follows:

.. literalinclude:: ../samples.tsv

The ``fastq1`` and ``fastq2`` columns should contain paths to the input files
of each of the pairs, which are expected to be fastq files. These paths can
either be provided as local relative/absolute paths, or as remote http/ftp urls.
Note that relative file paths are taken relative to the input directory
defined in the configuration file (see below for more details), if specified.

The ``lane`` column is used to distinguish sequencing data from the same sample
that has been sequenced in different lanes. This column can be filled with
dummy values (i.e. L999) if lane information is not available and samples
were sequenced on a single lane.

Pipeline configuration
----------------------

The individual steps of the pipeline are configured using the ``config.yaml``
file. This config file contains three different sections, which define
configurations for the overall workflow, for the inputs and for each specific
rule, respectively.

General options
~~~~~~~~~~~~~~~

The first section defines options regarding the overall workflow. Currently
this provides a single option, ``pdx``, which defines whether the standard
version or the PDX version of the workflow is used. Note that if the PDX
workflow is used, a few PDX-specific rules may require additional configuration
(see below for more details).

.. literalinclude:: ../config.yaml
    :lines: 1-6


Input options
~~~~~~~~~~~~~

The second section defines several options regarding the handling of the
input files:

.. literalinclude:: ../config.yaml
    :lines: 9-20

Here, ``dir`` is an optional value that defines the directory containing
the input files. If given, file paths provided in ``samples.tsv`` are
sought relative to this directory. Its value is ignored if http/ftp urls
are used for the inputs.

The ``ftp`` section defines the username/password to use when downloading
samples over an ftp connection. These values can be ommitted when downloading
files from an anonymous ftp server.

Rule options
~~~~~~~~~~~~

The third section provides detailed configuration options for the different
steps of the pipeline. In general, each step of the pipeline has a set of
configurable options under the same name as the step itself. The options
themselves are specific for each step and the corresponding tool, but each step
typically has an ``extra`` option, which allows you to pass arbitrary command
line arguments to the underlying tool.

.. literalinclude:: ../config.yaml
    :lines: 23-

This section is divided into two sub-sections: general and PDX-specific. The
PDX-specific section contains additional options for rules that are only used
in the PDX workflow.

Note that ``index_host`` (under the ``bwa`` options) should also be
defined when processing PDX samples, as this additional index of the host
genome is required to distinguish host/graft reads in PDX samples. In this
case, ``index`` should refer to the index of the graft genome.

PDX options
~~~~~~~~~~~

The third section defines extra configuration options for processing
PDX samples. If provided, the pipeline performs a number of extra steps to
separate reads from the host and graft organisms of the PDX samples (which are
typically mouse and human, respectively).

.. literalinclude:: ../config.yaml
    :lines: 58-

The most important option in this section is ``bwa_index_host``, which defines
the additional bwa index for the host genome. The index supplied in the general
section is used as the index for the graft genome. Extra options for the
``disamgibuate`` and ``sambamba_sort`` steps can be provided using the
remaining options.
