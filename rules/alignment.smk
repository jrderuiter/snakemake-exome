from os import path


rule bwa:
    input:
        ['fastq/trimmed/{sample}.{lane}.R1.fastq.gz',
         'fastq/trimmed/{sample}.{lane}.R2.fastq.gz'],
    output:
        temp('bam/aligned/{sample}.{lane}.bam')
    params:
        index=config['bwa']['index'],
        extra=config['bwa']['extra'],
        sort='picard',
        sort_order='queryname',
        sort_extra=config['bwa']['sort_extra']
    threads:
        config['bwa']['threads']
    log:
        'logs/bwa/{sample}.{lane}.log'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/bwa/mem')


def merge_inputs(wildcards):
    lanes = get_sample_lanes(wildcards.sample)

    file_paths = ['bam/aligned/{}.{}.bam'.format(
                    wildcards.sample, lane)
                  for lane in lanes]

    return file_paths


rule picard_merge_bam:
    input:
        merge_inputs
    output:
        'bam/merged/{sample}.bam'
    params:
        config['picard_merge_bam']['extra']
    log:
        'logs/picard_merge_bam/{sample}.log'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/picard/mergesamfiles')


rule picard_mark_duplicates:
    input:
        'bam/merged/{sample}.bam'
    output:
        bam='bam/deduped/{sample}.bam',
        metrics='qc/picard_mark_duplicates/{sample}.metrics'
    params:
        config['picard_mark_duplicates']['extra']
    log:
        'logs/picard_mark_duplicates/{sample}.log'
    wrapper:
        '0.15.4/bio/picard/markduplicates'


rule samtools_index:
    input:
        'bam/deduped/{sample}.bam'
    output:
        'bam/deduped/{sample}.bam.bai'
    wrapper:
        "0.15.4/bio/samtools/index"
