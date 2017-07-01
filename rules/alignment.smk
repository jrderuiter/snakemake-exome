rule bwa:
    input:
        ["fastq/trimmed/{sample}.{lane}.R1.fastq.gz",
         "fastq/trimmed/{sample}.{lane}.R2.fastq.gz"],
    output:
        temp("bam/aligned/{sample}.{lane}.bam")
    params:
        index=config["bwa"]["index"],
        extra=config["bwa"]["extra"],
        sort="samtools",
        sort_order="coordinate",
        sort_extra=config["bwa"]["sort_extra"]
    threads:
        config["bwa"]["threads"]
    log:
        "logs/bwa/{sample}.{lane}.log"
    wrapper:
        "0.17.0/bio/bwa/mem"


def merge_inputs(wildcards):
    lanes = get_sample_lanes(wildcards.sample)

    file_paths = ["bam/aligned/{}.{}.bam".format(
                    wildcards.sample, lane)
                  for lane in lanes]

    return file_paths

rule samtools_merge:
    input:
        merge_inputs
    output:
        temp("bam/merged/{sample}.bam")
    params:
        config["samtools_merge"]["extra"] + " -n"
    threads:
        config["samtools_merge"]["threads"]
    wrapper:
        "0.17.0/bio/samtools/merge"

rule picard_mark_duplicates:
    input:
        "bam/merged/{sample}.bam"
    output:
        bam="bam/final/{sample}.bam",
        metrics="qc/picard_mark_duplicates/{sample}.metrics"
    params:
        config["picard_mark_duplicates"]["extra"]
    log:
        "logs/picard_mark_duplicates/{sample}.log"
    wrapper:
        "0.17.0/bio/picard/markduplicates"


rule samtools_index:
    input:
        "bam/final/{sample}.bam"
    output:
        "bam/final/{sample}.bam.bai"
    wrapper:
        "0.17.0/bio/samtools/index"
