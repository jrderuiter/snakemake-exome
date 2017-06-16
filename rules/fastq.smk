from os import path

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider


HTTP = HTTPRemoteProvider()


def cutadapt_inputs(wildcards):
    # Lookup input paths.
    key = (wildcards.sample, wildcards.lane)
    row = samples.set_index(['sample', 'lane']).loc[key]

    inputs = list(row[['fastq1', 'fastq2']])

    # Wrap as URL if needed.
    if inputs[0].startswith('http'):
        inputs = [HTTP.remote(input_, keep_local=True) for input_ in inputs]

    return inputs


rule cutadapt:
    input:
        cutadapt_inputs
    output:
        fastq1=temp('fastq/trimmed/{sample}.{lane}.R1.fastq.gz'),
        fastq2=temp('fastq/trimmed/{sample}.{lane}.R2.fastq.gz'),
        qc='qc/cutadapt/{sample}.{lane}.qc.txt'
    params:
        config['cutadapt']['extra']
    log:
        'logs/cutadapt/{sample}.{lane}.log'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/cutadapt/pe')
