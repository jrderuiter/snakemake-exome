import pandas as pd

if not config:
    raise ValueError("A config file must be provided using --configfile")

def _invert_dict(d):
    return dict( (v,k) for k in d for v in d[k] )

_unit_sample_lookup = _invert_dict(config['samples'])


################################################################################
# Functions                                                                    #
################################################################################

def get_samples():
    """Returns list of samples."""
    return list(config["samples"].keys())

def get_units():
    """Returns list of sample/lane identifiers."""
    return list(config["units"].keys())

def get_sample_units(sample):
    """Returns available units for given sample."""
    return config["samples"][sample]

def get_sample_for_unit(unit):
    """Returns sample for given unit."""
    return _unit_sample_lookup[unit]


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
include: "rules/alignment.smk"
include: "rules/qc.smk"
