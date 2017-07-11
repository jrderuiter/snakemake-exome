def bwa_extra(bwa_config):
    """Returns extra arguments for BWA based on config.

    Ensures that readgroup information is included in the arguments.
    """

    extra_args = bwa_config.get("extra", "")
    extra_args += " -R " + bwa_config["readgroup"]

    return extra_args.strip()


if config["options"]["pdx"]:

    rule bwa_graft:
        input:
            ["fastq/trimmed/{sample}.{lane}.R1.fastq.gz",
             "fastq/trimmed/{sample}.{lane}.R2.fastq.gz"],
        output:
            temp("bam/aligned/{sample}.{lane}.graft.bam")
        params:
            index=config["bwa"]["index"],
            extra=bwa_extra(config["bwa"]),
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
            extra=bwa_extra(config["bwa"]),
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

else:

    rule bwa:
        input:
            ["fastq/trimmed/{sample}.{lane}.R1.fastq.gz",
             "fastq/trimmed/{sample}.{lane}.R2.fastq.gz"],
        output:
            temp("bam/aligned/{sample}.{lane}.bam")
        params:
            index=config["bwa"]["index"],
            extra=bwa_extra(config["bwa"]),
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
            config["samtools_merge"]["extra"]
        threads:
            config["samtools_merge"]["threads"]
        wrapper:
            "0.17.0/bio/samtools/merge"


def mark_duplicates_input(wildcards):
    """Return inputs for mark_duplicates, depending on PDX status."""

    if config["options"]["pdx"]:
        input_path = "bam/sorted/{sample}.bam"
    else:
        input_path = "bam/merged/{sample}.bam"

    return input_path.format(sample=wildcards.sample)


rule picard_mark_duplicates:
    input:
        mark_duplicates_input
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
