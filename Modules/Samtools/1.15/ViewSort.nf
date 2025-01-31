process ViewSort {
    tag {"Samtools ViewSort ${sample_id} - ${rg_id}"}
    label 'Samtools_1_15'
    label 'Samtools_1_15_ViewSort'
    container = 'quay.io/biocontainers/samtools:1.15.1--h1170115_0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(val(sample_id), val(rg_id), path(sam_file))

    output:
        tuple(
            val(sample_id),
            val(rg_id),
            path("${sam_file.baseName}.sort.bam"),
            path("${sam_file.baseName}.sort.bam.bai"),
            emit: bam_file
        )

    script:
        """
        samtools view --threads ${task.cpus} -S -b ${sam_file} | \
        samtools sort --threads ${task.cpus} -m 4G -o ${sam_file.baseName}.sort.bam##idx##${sam_file.baseName}.sort.bam.bai /dev/stdin --write-index
        """
}
