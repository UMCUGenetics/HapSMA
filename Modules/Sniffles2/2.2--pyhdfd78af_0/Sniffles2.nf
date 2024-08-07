process Sniffles2 {
    tag { "Sniffles2 ${bam_file.baseName}" }
    label 'Sniffles2_2_2'
    container = 'quay.io/biocontainers/sniffles:2.2--pyhdfd78af_0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(path(bam_file), path(bai_file))

    output:
        path("*")

    script:
        """
        sniffles \
            -i ${bam_file} \
            -v ${bam_file.baseName}.vcf \
            --threads=${task.cpus} \
            ${params.optional}
        """
}
