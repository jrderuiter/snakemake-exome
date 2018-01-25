def bwa_extra(wildcards):
    """Generates bwa mem extra arguments."""

    extra = list(config["rules"]["bwa"]["extra"])

    readgroup_str = ('\"@RG\\tID:{unit}\\tSM:{sample}\\t'
                     'LB:{sample}\\tPU:{unit}\\t'
                     'PL:{platform}\\tCN:{centre}\"')

    readgroup_str = readgroup_str.format(
        sample=get_sample_for_unit(wildcards.unit),
        unit=wildcards.unit,
        platform=config["options"]["readgroup"]["platform"],
        centre=config["options"]["readgroup"]["centre"])

    extra += ['-R ' + readgroup_str]

    return " ".join(extra)


if config["options"]["pdx"]:

    rule bwa_graft:
        input:
            ["fastq/trimmed/{unit}.R1.fastq.gz",
             "fastq/trimmed/{unit}.R2.fastq.gz"],
        output:
            temp("bam/aligned/{unit}.graft.bam")
        params:
            index=config["references"]["bwa_index"],
            extra=lambda wc: bwa_extra(wc),
            sort="samtools",
            sort_order="queryname",
            sort_extra=" ".join(config["rules"]["bwa"]["sort_extra"])
        threads:
            config["rules"]["bwa"]["threads"]
        log:
            "logs/bwa/{unit}.graft.log"
        wrapper:
            "0.17.0/bio/bwa/mem"


    rule bwa_host:
        input:
            ["fastq/trimmed/{unit}.R1.fastq.gz",
             "fastq/trimmed/{unit}.R2.fastq.gz"]
        output:
            temp("bam/aligned/{unit}.host.bam")
        params:
            index=config["references"]["bwa_index_host"],
            extra=lambda wc: bwa_extra(wc),
            sort="samtools",
            sort_order="queryname",
            sort_extra=" ".join(config["rules"]["bwa"]["sort_extra"])
        threads:
            config["rules"]["bwa"]["threads"]
        log:
            "logs/bwa/{unit}.host.log"
        wrapper:
            "0.17.0/bio/bwa/mem"


    def merge_inputs(wildcards):
        units = get_sample_units(wildcards.sample)

        file_paths = ["bam/aligned/{}.{}.bam"
                      .format(unit, wildcards.organism)
                      for unit in units]

        return file_paths


    rule samtools_merge:
        input:
            merge_inputs
        output:
            temp("bam/merged/{sample}.{organism}.bam")
        params:
            " ".join(config["rules"]["samtools_merge"]["extra"] + ["-n"])
        threads:
            config["rules"]["samtools_merge"]["threads"]
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
            extra=" ".join(config["rules"]["disambiguate"]["extra"])
        wrapper:
            "0.17.0/bio/ngs-disambiguate"


    rule sambamba_sort:
        input:
            "bam/disambiguate/{sample}.graft.bam"
        output:
            "bam/sorted/{sample}.bam"
        params:
            " ".join(config["rules"]["sambamba_sort"]["extra"])
        threads:
            config["rules"]["sambamba_sort"]["threads"]
        wrapper:
            "0.17.0/bio/sambamba/sort"

else:

    rule bwa:
        input:
            ["fastq/trimmed/{unit}.R1.fastq.gz",
             "fastq/trimmed/{unit}.R2.fastq.gz"],
        output:
            temp("bam/aligned/{unit}.bam")
        params:
            index=config["references"]["bwa_index"],
            extra=lambda wc: bwa_extra(wc),
            sort="samtools",
            sort_order="coordinate",
            sort_extra=" ".join(config["rules"]["bwa"]["sort_extra"])
        threads:
            config["rules"]["bwa"]["threads"]
        log:
            "logs/bwa/{unit}.log"
        wrapper:
            "0.17.0/bio/bwa/mem"


    def merge_inputs(wildcards):
        units = get_sample_units(wildcards.sample)
        return ["bam/aligned/{}.bam".format(unit) for unit in units]


    rule samtools_merge:
        input:
            merge_inputs
        output:
            temp("bam/merged/{sample}.bam")
        params:
            config["rules"]["samtools_merge"]["extra"]
        threads:
            config["rules"]["samtools_merge"]["threads"]
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
        config["rules"]["picard_mark_duplicates"]["extra"]
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
