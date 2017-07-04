rule bwa_graft:
    input:
        ["fastq/trimmed/{sample}.{lane}.R1.fastq.gz",
         "fastq/trimmed/{sample}.{lane}.R2.fastq.gz"],
    output:
        temp("bam/aligned/{sample}.{lane}.graft.bam")
    params:
        index=config["bwa"]["index"],
        extra=config["bwa"]["extra"],
        sort="samtools",
        sort_order="queryname",
        sort_extra=config["bwa"]["sort_extra"]
    threads:
        config["bwa"]["threads"]
    log:
        "logs/bwa/{sample}.{lane}.graft.log"
    wrapper:
        "0.17.0/bio/bwa/mem"


rule bwa_host:
    input:
        ["fastq/trimmed/{sample}.{lane}.R1.fastq.gz",
         "fastq/trimmed/{sample}.{lane}.R2.fastq.gz"]
    output:
        temp("bam/aligned/{sample}.{lane}.host.bam")
    params:
        index=config["bwa"]["index_host"],
        extra=config["bwa"]["extra"],
        sort="samtools",
        sort_order="queryname",
        sort_extra=config["bwa"]["sort_extra"]
    threads:
        config["bwa"]["threads"]
    log:
        "logs/bwa/{sample}.{lane}.host.log"
    wrapper:
        "0.17.0/bio/bwa/mem"


def merge_inputs(wildcards):
    lanes = get_sample_lanes(wildcards.sample)

    file_paths = ["bam/aligned/{}.{}.{}.bam"
                  .format(wildcards.sample, lane, wildcards.organism)
                  for lane in lanes]

    return file_paths


rule samtools_merge:
    input:
        merge_inputs
    output:
        temp("bam/merged/{sample}.{organism}.bam")
    params:
        config["samtools_merge"]["extra"] + " -n"
    threads:
        config["samtools_merge"]["threads"]
    wrapper:
        "0.17.0/bio/samtools/merge"


rule disambiguate:
    input:
        a="bam/merged/{sample}.graft.bam",
        b="bam/merged/{sample}.host.bam"
    output:
        a_ambiguous=temp("bam/disambiguate/{sample}.graft.ambiguous.bam"),
        b_ambiguous=temp("bam/disambiguate/{sample}.host.ambiguous.bam"),
        a_disambiguated=temp("bam/disambiguate/{sample}.graft.bam"),
        b_disambiguated=temp("bam/disambiguate/{sample}.host.bam"),
        summary="qc/disambiguate/{sample}.txt"
    params:
        algorithm="bwa",
        prefix="{sample}",
        extra=config["disambiguate"]["extra"]
    wrapper:
        "0.17.0/bio/ngs-disambiguate"


rule sambamba_sort:
    input:
        "bam/disambiguate/{sample}.graft.bam"
    output:
        "bam/sorted/{sample}.bam"
    params:
        config["sambamba_sort"]["extra"]
    threads:
        config["sambamba_sort"]["threads"]
    wrapper:
        "0.17.0/bio/sambamba/sort"


rule picard_mark_duplicates:
    input:
        "bam/sorted/{sample}.bam"
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
