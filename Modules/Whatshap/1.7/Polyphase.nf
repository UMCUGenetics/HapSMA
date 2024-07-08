process Polyphase {
    tag {"Whatshap_Phase ${sample_id}"}
    label 'Whatshap_1_7'
    label 'Whatshap_1_7_Polyphase'
    container = 'quay.io/biocontainers/whatshap:1.7--py310h30d9df9_0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(val(sample_id), path(bam_file), path(bai_file), path(vcf_file), val(ploidy))

    output:
        tuple(val(sample_id), path("${vcf_file.simpleName}_WH.vcf"), val(ploidy))

    script:
        """
        whatshap polyphase \
            $vcf_file $bam_file \
            --ploidy $ploidy \
            --reference $params.genome \
            --ignore-read-groups \
            -o ${vcf_file.simpleName}_WH.vcf
        """
}
