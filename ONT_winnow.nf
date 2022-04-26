#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// Utils modules
include extractAllFastqFromDirONT from './NextflowModules/Utils/fastq.nf'
include extractAllFast5FromDirONT from './NextflowModules/Utils/fast5.nf'
include ExportParams as Workflow_ExportParams from './NextflowModules/Utils/workflow.nf'

//Re-basecalling
//optional

// Mapping modules
include Mapping as WinnowmapMapping from './NextflowModules/Winnowmap/2.0.3/Mapping.nf' params(
    genome_fasta: "$params.genome", optional: ''
)

include ViewSort as Sambamba_ViewSort from './NextflowModules/Sambamba/0.7.0/ViewSort.nf' 
include ViewSort as Sambamba_ViewSort_Winnow from './NextflowModules/Sambamba/0.7.0/ViewSort.nf'
include Merge as Sambamba_Merge from './NextflowModules/Sambamba/0.7.0/Merge.nf'
include Filter as Sambamba_Filter from './NextflowModules/Sambamba/0.7.0/Filter.nf'
include Split as Sambamba_Split from './NextflowModules/Sambamba/0.7.0/Split.nf'

include ToSAM as Sambamba_ToSam from './NextflowModules/Sambamba/0.7.0/ToSAM.nf'
include ToSAM as Sambamba_ToSam_hap1 from './NextflowModules/Sambamba/0.7.0/ToSAM.nf'
include ToSAM as Sambamba_ToSam_hap2 from './NextflowModules/Sambamba/0.7.0/ToSAM.nf'
include ToSAM as Sambamba_ToSam_nohap from './NextflowModules/Sambamba/0.7.0/ToSAM.nf'

include LongshotPhase from './NextflowModules/Longshot/0.4.1/Phase.nf'
include NanopolishIndex from './NextflowModules/Nanopolish/0.13.2/Index.nf'
include NanopolishCallMethylation from './NextflowModules/Nanopolish/0.13.2/CallMethylation.nf'
include Index as STRiqueIndex from './NextflowModules/STRique/0.4.2/Index.nf'

include CallRepeat as STRiqueCallRepeat from './NextflowModules/STRique/0.4.2/CallRepeats.nf'
include CallRepeat as STRiqueCallRepeat_hap1 from './NextflowModules/STRique/0.4.2/CallRepeats.nf'
include CallRepeat as STRiqueCallRepeat_hap2 from './NextflowModules/STRique/0.4.2/CallRepeats.nf'
include CallRepeat as STRiqueCallRepeat_nohap from './NextflowModules/STRique/0.4.2/CallRepeats.nf'

def fastq_files = extractAllFastqFromDirONT(params.fastq_path)
def fast5_files = extractAllFast5FromDirONT(params.fast5_path)
def analysis_id = params.outdir.split('/')[-1]
//def sample_id = params.sample_id

workflow {
    // Mapping
    WinnowmapMapping(fastq_files) 

    // SAMtoBAM
    Sambamba_ViewSort(WinnowmapMapping.out)

    // MergeSort BAMs
    Sambamba_Merge(Sambamba_ViewSort.out.map{sample_id, fastq_id, bam_file, bai_file -> [sample_id, bam_file, bai_file]}.groupTuple())

    // Filter BAM on roi
    Sambamba_Filter(Sambamba_Merge.out)

    //Phasing BAM
    LongshotPhase(Sambamba_Filter.out) 

    //SplitPhasedBam
    Sambamba_Split(LongshotPhase.out)    
 
    //Index FAST5 nanopolish 
    NanopolishIndex(fastq_files)

    //Methylation calling
    NanopolishCallMethylation(
        Sambamba_ViewSort.out.map{
            sample_id, fastq_id, bam_files, bai_files -> [fastq_id, bam_files, bai_files]
        }.join(NanopolishIndex.out.map{
            fastq, fastq_id, sample_id, run_id, index, fai, gzi, readdb -> [fastq_id, fastq, index, fai, gzi, readdb]
        })
    )

    //Convert BAM to SAM #### > perhaps only for phased BAM files?
    Sambamba_ToSam(Sambamba_Filter.out)
    Sambamba_ToSam_hap1(Sambamba_Split.out.map{sample_id, hap1_bam, hap1_bai, hap2_bam, hap2_bai, nohap_bam, nohap_bai -> [sample_id, hap1_bam, hap1_bai]})
    Sambamba_ToSam_hap2(Sambamba_Split.out.map{sample_id, hap1_bam, hap1_bai, hap2_bam, hap2_bai, nohap_bam, nohap_bai -> [sample_id, hap2_bam, hap2_bai]})
    Sambamba_ToSam_nohap(Sambamba_Split.out.map{sample_id, hap1_bam, hap1_bai, hap2_bam, hap2_bai, nohap_bam, nohap_bai -> [sample_id, nohap_bam, nohap_bai]})

    //STRique index
    STRiqueIndex(fast5_files)


    //Concat all fofn files
    sample_id = Sambamba_ViewSort.out.map{sample_id, fastq_id, bam_file, bai_file -> sample_id}.unique()
    ConcatFofn(STRiqueIndex.out.collect(), sample_id)
    
    //Repeat calling #### > perhaps only for phased BAM files?
    STRiqueCallRepeat(Sambamba_ToSam.out, ConcatFofn.out, fast5_files.collect())
    STRiqueCallRepeat_hap1(Sambamba_ToSam_hap1.out, ConcatFofn.out, fast5_files.collect())
    STRiqueCallRepeat_hap2(Sambamba_ToSam_hap2.out, ConcatFofn.out, fast5_files.collect())
    STRiqueCallRepeat_nohap(Sambamba_ToSam_nohap.out, ConcatFofn.out, fast5_files.collect())

    SaveInputFile(params.roi)
 
    // Create log files: Repository versions and Workflow params
    VersionLog()
    Workflow_ExportParams()
}

// Workflow completion notification
workflow.onComplete {
    // HTML Template
    def template = new File("$baseDir/assets/workflow_complete.html")
    def binding = [
        runName: analysis_id,
        workflow: workflow
    ]
    def engine = new groovy.text.GStringTemplateEngine()
    def email_html = engine.createTemplate(template).make(binding).toString()

    // Send email
    if (workflow.success) {
        def subject = "ONT Workflow Successful: ${analysis_id}"
        sendMail(
            to: params.email.trim(),
            subject: subject,
            body: email_html,
            attach: "${params.outdir}/QC/${analysis_id}_multiqc_report.html"
        )

    } else {
        def subject = "ONT Workflow Failed: ${analysis_id}"
        sendMail(to: params.email.trim(), subject: subject, body: email_html)
    }
}

// Custom processes
process ConcatFofn{
    // Custom process to concat all fofn files
    tag {"Concat Fofn ${sample_id}"}
    label 'Concat_Fofn'
    shell = ['/bin/bash', '-eo', 'pipefail']
    
    input:
        path(fofn_files)
        val(sample_id)
    
    output:
        //path("${fofn_files[0].baseName}.fofn")
        path("${sample_id}.fofn")

    script:
        fofn  = fofn_files.join(' ')
        //println fofn_files[0]
        """
        cat ${fofn} > ${sample_id}.fofn
        """
}

process SaveInputFile {
    tag {"SaveInputFile ${analysis_id}"}
    label 'SaveInputFile'
    shell = ['/bin/bash', '-euo', 'pipefail']
    cache = false  //Disable cache to force a new files to be copied.

    input:
       path(roi)

    output:
       path(roi)

    script:
        """
        """
}

process VersionLog {
    // Custom process to log repository versions
    tag {"VersionLog ${analysis_id}"}
    label 'VersionLog'
    shell = ['/bin/bash', '-eo', 'pipefail']
    cache = false  //Disable cache to force a new version log when restarting the workflow.

    output:
        path('repository_version.log')

    script:
        """
        echo 'DxNextflowONT' > repository_version.log
        git --git-dir=${workflow.projectDir}/.git log --pretty=oneline --decorate -n 2 >> repository_version.log
        """
}
