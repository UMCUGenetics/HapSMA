// Original code from: https://github.com/UMCUGenetics/NextflowModules - MIT License - Copyright (c) 2019 UMCU Genetics

process Merge {
    tag {"Samtools Merge ${sample_id}"}
    label 'Samtools_1_15'
    label 'Samtools_1_15_Merge'
    container = 'quay.io/biocontainers/samtools:1.15.1--h1170115_0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(val(sample_id), path(bam_files))

    output:
        tuple(val(sample_id), path("${sample_id}.bam"), emit: bam_file)

    script:
        """
        samtools merge -@ ${task.cpus} ${sample_id}.bam ${bam_files}
        """
}
