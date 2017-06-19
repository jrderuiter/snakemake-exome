rule freebayes:
    input:
        samples=expand('bam/deduped/{sample}.bam', sample=get_samples()),
        indices=expand('bam/deduped/{sample}.bam.bai', sample=get_samples()),
    output:
        'vcf/calls.vcf'
    params:
        reference=config['freebayes']['reference'],
        targets=config['freebayes']['targets'],
        extra=config['freebayes']['extra']
    log:
        'logs/freebayes.log'
    shell:
        'freebayes {params.extra} --fasta-reference {params.reference}'
        ' --targets {params.targets} {input.samples} > {output[0]} 2> {log}'
