rule multiqc:
    input:
        directory='.',
        fastqc=expand('qc/fastqc/{sample_lane}.{pair}_fastqc.html',
                      sample_lane=get_samples_with_lane(), pair=['R1', 'R2'])
    output:
        'qc/multiqc_report.html'
    params:
        output_dir='qc',
        extra=config['multiqc']['extra']
    shell:
        'multiqc {params.extra} --force -o'
        ' {params.output_dir} {input.directory}'


rule fastqc:
    input:
        'fastq/trimmed/{sample}.{lane}.{pair}.fastq.gz'
    output:
        html='qc/fastqc/{sample}.{lane}.{pair}_fastqc.html',
        zip='qc/fastqc/{sample}.{lane}.{pair}_fastqc.zip'
    params:
        config['fastqc']['extra']
    wrapper:
        'file:///home/j.d.ruiter/workflows/snakemake-wrappers/bio/fastqc'


rule samtools_stats:
    input:
        'bam/deduped/{sample}.txt'
    output:
        'qc/samtools_stats/{sample}.txt'
    shell:
        'samtools stats {input} > {output}'
