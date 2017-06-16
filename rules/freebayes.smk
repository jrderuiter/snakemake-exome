rule freebayes:
    input:
        samples=expand('bam/deduped/{sample}.bam', sample=get_samples()),
        indices=expand('bam/deduped/{sample}.bam.bai', sample=get_samples()),
        ref=config['freebayes']['ref']
    output:
        'vcf/calls.vcf'
    params:
        config['freebayes']['extra']
    log:
        'logs/freebayes.log'
    shell:
        'freebayes {params} -f {input.ref} {input.samples}'
        ' > {output[0]} 2> {log}'
