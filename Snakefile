import pandas as pd

configfile: 'config.yaml'

################################################################################
# Globals                                                                      #
################################################################################

samples = pd.read_csv('samples.tsv', sep='\t')
is_pdx = 'pdx' in config


################################################################################
# Functions                                                                    #
################################################################################

def get_samples():
    """Returns list of samples."""
    return list(samples['sample'].unique())


def get_samples_with_lane():
    """Returns list of sample/lane identifiers."""
    return list((samples['sample'] + '.' + samples['lane']).unique())


def get_sample_lanes(sample):
    """Returns available lanes for given sample."""
    subset = samples.loc[samples['sample'] == sample]
    return list(subset['lane'].unique())


################################################################################
# Rules                                                                        #
################################################################################

rule all:
    input:
        expand("bam/final/{sample}.bam", sample=get_samples()),
        expand("bam/final/{sample}.bam.bai", sample=get_samples()),
        "qc/multiqc_report.html"

include: "rules/input.smk"
include: "rules/fastq.smk"

if is_pdx:
    include: "rules/alignment_pdx.smk"
else:
    include: "rules/alignment.smk"

include: "rules/qc.smk"
