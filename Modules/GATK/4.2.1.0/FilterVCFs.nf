// Original code from: https://github.com/UMCUGenetics/NextflowModules - MIT License - Copyright (c) 2019 UMCU Genetics

process FilterVcfs {
    tag {"GATK FilterVCFs ${sample_id}"}
    label 'GATK_4_2_1_0'
    label 'GATK_4_2_1_0_FilterVcfs'
    container = 'broadinstitute/gatk:4.2.1.0'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
        tuple(val(sample_id), path(bam_file), path(bai_file), path(vcf_file), path(vcf_index), val(ploidy))
        
    output:
        tuple(val(sample_id), path(bam_file), path(bai_file), path("${vcf_file.simpleName}_snv.vcf"), val(ploidy))
        
    script:
        """
        gatk --java-options "-Xmx${task.memory.toGiga()-4}G -Djava.io.tmpdir=\$TMPDIR" SelectVariants \
            --reference $params.genome \
            -V ${vcf_file} \
            --select-type-to-include $params.filter \
            -O ${vcf_file.simpleName}_snv.vcf
        """
}
