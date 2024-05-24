process FilterCondition {
    tag {"Sambamba Filter Condition ${bam_file}"}
    label 'Sambamba_1_0_0_Filter_Condition'
    container = 'quay.io/biocontainers/sambamba:1.0--h98b6b92_0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(path(bam_file), path(bai_file))

    output:
        tuple(path("${bam_file.simpleName}_condition.bam"), path("${bam_file.simpleName}_condition.bam.bai"))

    script:
        """
        sambamba view -t ${task.cpus} -f bam \
        -F "${params.conditions}" \
        ${bam_file} \
        -o  ${bam_file.simpleName}_condition.bam
        """
}

process FilterHaplotypePhaseset {
    tag {"Sambamba Filter Haplotype ${bam_file} ${hp}"}
    label 'Sambamba_1_0_0_Filter_Haplotype'
    container = 'quay.io/biocontainers/sambamba:1.0--h98b6b92_0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(path(bam_file), path(bai_file), val(hp), val(ps))

    output:
        tuple(path("${bam_file.simpleName}_hap${hp}_ps${ps}.bam"), path("${bam_file.simpleName}_hap${hp}_ps${ps}.bam.bai"))

    script:
        """
        sambamba view -t ${task.cpus} -f bam \
        -F "[HP] == ${hp} and [PS] == ${ps}" \
        ${bam_file} \
        -o  ${bam_file.simpleName}_hap${hp}_ps${ps}.bam
        """
}
