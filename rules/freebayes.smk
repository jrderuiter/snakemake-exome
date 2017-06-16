rule freebayes:
    input:
        samples=expand('bam/deduped/{sample}.bam', sample=get_samples()),
        indices=expand('bam/deduped/{sample}.bam.bai', sample=get_samples()),
    output:
        'vcf/calls.vcf'
    params:
        reference=config['freebayes']['reference'],
        extra=config['freebayes']['extra']
    log:
        'logs/freebayes.log'
    shell:
        'freebayes {params.extra} -f {params.reference} {input.samples}'
        ' > {output[0]} 2> {log}'
