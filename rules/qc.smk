from os import path


rule multiqc:
    input:
        directory='.',
        fastqc=expand('qc/fastqc/{sample_lane}.{pair}_fastqc.html',
                      sample_lane=get_samples_with_lane(), pair=['R1', 'R2']),
        samtools_stats=expand('qc/samtools_stats/{sample}.txt',
                              sample=get_samples()),
        hs_metrics=expand('qc/picard_collect_hs_metrics/{sample}.txt',
                          sample=get_samples()),
        dedupe_metrics=expand('qc/picard_mark_duplicates/{sample}.metrics',
                              sample=get_samples())
    output:
        'qc/multiqc_report.html'
    params:
        config['multiqc']['extra']
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/multiqc')


rule fastqc:
    input:
        'fastq/trimmed/{sample}.{lane}.{pair}.fastq.gz'
    output:
        html='qc/fastqc/{sample}.{lane}.{pair}_fastqc.html',
        zip='qc/fastqc/{sample}.{lane}.{pair}_fastqc.zip'
    params:
        config['fastqc']['extra']
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/fastqc')


rule samtools_stats:
    input:
        'bam/deduped/{sample}.bam'
    output:
        'qc/samtools_stats/{sample}.txt'
    shell:
        'file://' + path.join(workflow.basedir, 'wrappers/samtools/stats')


rule picard_collect_hs_metrics:
    input:
        'bam/deduped/{sample}.bam'
    output:
        'qc/picard_collect_hs_metrics/{sample}.txt'
    params:
        # Baits and targets should be given as interval lists. These can
        # can be generated from bed files using picard BedToIntervalList.
        reference=config['picard_collect_hs_metrics']['reference'],
        bait_intervals=config['picard_collect_hs_metrics']['bait_intervals'],
        target_intervals=config['picard_collect_hs_metrics']['target_intervals'],
        extra=config['picard_collect_hs_metrics']['extra']
    log:
        'logs/picard_collect_hs_metrics/{sample}.log'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/fastqc')
