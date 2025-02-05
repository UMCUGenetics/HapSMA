#!/usr/bin/env nextflow

// Utils modules
include { AddReplaceReadgroup as Samtools_AddReplaceReadgroup } from './Modules/Samtools/1.15/AddReplaceReadgroup.nf'
include { Annotate as Bcftools_Annotate_Clair3_Bed } from './Modules/bcftools/1.15.1--h0ea216a_0/Annotate.nf'
include { Annotate as Bcftools_Annotate_Clair3_Region } from './Modules/bcftools/1.15.1--h0ea216a_0/Annotate.nf'
include { Annotate as Bcftools_Annotate_Bed } from './Modules/bcftools/1.15.1--h0ea216a_0/Annotate.nf'
include { Annotate as Bcftools_Annotate_Region } from './Modules/bcftools/1.15.1--h0ea216a_0/Annotate.nf'
include { CollectMultipleMetrics as PICARD_CollectMultipleMetrics } from './Modules/Picard/2.26.4/CollectMultipleMetrics.nf' params(genome:"$params.genome_fasta", optional: "PROGRAM=null PROGRAM=CollectAlignmentSummaryMetrics METRIC_ACCUMULATION_LEVEL=null METRIC_ACCUMULATION_LEVEL=SAMPLE")
include { CollectWgsMetrics as PICARD_CollectWgsMetrics } from './Modules/Picard/2.26.4/CollectWgsMetrics.nf' params(genome:"$params.genome_fasta", optional: "MINIMUM_MAPPING_QUALITY=1 MINIMUM_BASE_QUALITY=1 ")
include { ExportParams as Workflow_ExportParams } from './Modules/Utils/workflow.nf'
include { Fastq as Samtools_Fastq } from './Modules/Samtools/1.15/Fastq.nf' params(tags:" -T $params.tags", roi: params.roi_fastq)
include { FilterCondition as Sambamba_Filter_Condition } from './Modules/Sambamba/1.0.0/Filter.nf' params(conditions: params.conditions)
include { FilterHaplotypePhaseset as Sambamba_Filter_Haplotype_Phaseset_Bed } from './Modules/Sambamba/1.0.0/Filter.nf'
include { FilterHaplotypePhaseset as Sambamba_Filter_Haplotype_Phaseset_Region } from './Modules/Sambamba/1.0.0/Filter.nf'
include { FilterPairs as Duplex_FilterPairs } from './Modules/DuplexTools/0.2.17/FilterPairs.nf'
include { FilterSamReads as PICARD_FilterSamReads } from './Modules/Picard/2.26.4/FilterSamReads.nf' params(optional: " FILTER=excludeReadList")
include { FilterVcfs as GATK_FilterSNV_Target_Bed } from './Modules/GATK/4.2.1.0/FilterVCFs.nf' params(genome: params.genome_fasta, filter: "SNP")
include { FilterVcfs as GATK_FilterSNV_Target_Region } from './Modules/GATK/4.2.1.0/FilterVCFs.nf' params(genome: params.genome_fasta, filter: "SNP")
include { GetPhaseSet as GetPhaseSet_Bed } from './Modules/Utils/GetPhaseSet.nf'
include { GetPhaseSet as GetPhaseSet_Region } from './Modules/Utils/GetPhaseSet.nf'
include { HaplotypeCaller_SMN as GATK_HaplotypeCaller_Bed } from './Modules/GATK/4.2.1.0/HaplotypeCaller.nf' params(genome: params.genome_fasta, compress: true, extention: "_bed", optional:"--intervals $params.calling_target_bed --dont-use-soft-clipped-bases --pair-hmm-implementation  LOGLESS_CACHING")
include { HaplotypeCaller_SMN as GATK_HaplotypeCaller_Region } from './Modules/GATK/4.2.1.0/HaplotypeCaller.nf' params(genome: params.genome_fasta, compress: true, extention: "_region", optional:"--intervals $params.calling_target_region --dont-use-soft-clipped-bases --pair-hmm-implementation  LOGLESS_CACHING")
include { Haplotag as Whatshap_Haplotag_Target_Bed } from './Modules/Whatshap/1.7/Haplotag.nf' params (genome: params.genome_fasta, extention: "_bed", optional: "--ignore-read-groups")
include { Haplotag as Whatshap_Haplotag_Target_Region } from './Modules/Whatshap/1.7/Haplotag.nf' params (genome: params.genome_fasta, extention: "_region", optional: "--ignore-read-groups")
include { Index as Sambamba_Index } from './Modules/Sambamba/1.0.0/Index.nf'
include { Index as Sambamba_Index_Deduplex } from './Modules/Sambamba/1.0.0/Index.nf'
include { Index as Sambamba_Index_ReadGroup } from './Modules/Sambamba/1.0.0/Index.nf'
include { Index as Sambamba_Index_Target_Bed } from './Modules/Sambamba/1.0.0/Index.nf'
include { Index as Sambamba_Index_Target_Region } from './Modules/Sambamba/1.0.0/Index.nf'
include { Index as Sambamba_Index_Merge } from './Modules/Sambamba/1.0.0/Index.nf'
include { Minimap2 } from './Modules/Minimap2/2.26--he4a0461_1/Minimap2.nf' params(optional:params.minimap_param, genome_fasta: params.genome_fasta, platform: params.platform)
include { Merge as Samtools_Merge } from './Modules/Samtools/1.15/Merge.nf'
include { MultiQC } from './Modules/MultiQC/1.10/MultiQC.nf' params(optional: "--config $baseDir/assets/multiqc_config.yaml")
include { PairsFromSummary as Duplex_PairsFromSummary } from './Modules/DuplexTools/0.2.17/PairsFromSummary.nf'
include { Polyphase as Whatshap_Polyphase_Target_Bed } from './Modules/Whatshap/1.7/Polyphase.nf' params (genome: params.genome_fasta)
include { Polyphase as Whatshap_Polyphase_Target_Region } from './Modules/Whatshap/1.7/Polyphase.nf' params (genome: params.genome_fasta)
include { ReBasecallingGuppy } from './Modules/Utils/GuppyBasecalling.nf'
include { ViewSort as Samtools_ViewSort } from './Modules/Samtools/1.15/ViewSort.nf'
include { Clair3 as Clair3_Bed } from './Modules/Clair3/1.0.4--py39hf5e1c6e_3/Clair3.nf' params(
    genome: "$params.genome_fasta",
    clair3model: "$params.clair3model",
    optional: "$params.clair3_optional"
)
include { Clair3 as Clair3_Region } from './Modules/Clair3/1.0.4--py39hf5e1c6e_3/Clair3.nf' params(
    genome: "$params.genome_fasta",
    clair3model: "$params.clair3model",
    optional: "$params.clair3_optional"
)
include { Sniffles2 as Sniffles2_Bed } from './Modules/Sniffles2/2.2--pyhdfd78af_0/Sniffles2.nf' params(optional: "")
include { Sniffles2 as Sniffles2_Region } from './Modules/Sniffles2/2.2--pyhdfd78af_0/Sniffles2.nf' params(optional: "")
include { VariantFiltrationSnpIndel as GATK_VariantFiltration_Clair3_Bed } from './Modules/GATK/4.2.1.0/VariantFiltration.nf' params(
    genome: "$params.genome_fasta", snp_filter: "$params.clair3_snp_filter",
    snp_cluster: "$params.clair3_snp_cluster", indel_filter: "$params.gatk_indel_filter", compress: true
)
include { VariantFiltrationSnpIndel as GATK_VariantFiltration_Clair3_Region } from './Modules/GATK/4.2.1.0/VariantFiltration.nf' params(
    genome: "$params.genome_fasta", snp_filter: "$params.clair3_snp_filter",
    snp_cluster: "$params.clair3_snp_cluster", indel_filter: "$params.gatk_indel_filter", compress: true
)
include { VariantFiltrationSnpIndel as GATK_VariantFiltration_Bed } from './Modules/GATK/4.2.1.0/VariantFiltration.nf' params(
    genome: "$params.genome_fasta", snp_filter: "$params.gatk_snp_filter",
    snp_cluster: "$params.gatk_snp_cluster", indel_filter: "$params.gatk_indel_filter", compress: true
)
include { VariantFiltrationSnpIndel as GATK_VariantFiltration_Region } from './Modules/GATK/4.2.1.0/VariantFiltration.nf' params(
    genome: "$params.genome_fasta", snp_filter: "$params.gatk_snp_filter",
    snp_cluster: "$params.gatk_snp_cluster", indel_filter: "$params.gatk_indel_filter", compress: true
)
include { VersionLog } from './Modules/Utils/VersionLog.nf'
include { ZipIndex as Tabix_Zip_Index_Bed } from './Modules/Tabix/1.11/ZipIndex.nf'
include { ZipIndex as Tabix_Zip_Index_Region } from './Modules/Tabix/1.11/ZipIndex.nf'
include { ZipIndex as Tabix_Zip_Index_Bcftools_Clair3_Bed } from './Modules/Tabix/1.11/ZipIndex.nf'
include { ZipIndex as Tabix_Zip_Index_Bcftools_Clair3_Region } from './Modules/Tabix/1.11/ZipIndex.nf'
include { ZipIndex as Tabix_Zip_Index_Bcftools_Bed } from './Modules/Tabix/1.11/ZipIndex.nf'
include { ZipIndex as Tabix_Zip_Index_Bcftools_Region } from './Modules/Tabix/1.11/ZipIndex.nf'

def analysis_id = params.outdir.split('/')[-1]
ploidy_list = Channel.of(1..params.ploidy)

workflow {
    // Processes for start to list or create bam_file(s)
    if( params.start == 'bam' ){
        // Get fast5 and mapped bams from input folder
        bam_files = Channel.fromPath(params.input_path +  "/pass/*.bam").toList()
        summary_file = Channel.fromPath(params.input_path +  "/sequencing_summary.txt").toList()
    }
    else if( params.start == 'bam_single' || params.start == 'bam_single_remap'){
        //Get BAM file, and only BAM file as fast5 and summary are not available
        //TODO: remove param single_bam_type and automate file/path detection
        if(params.single_bam_type == "folder"){
            bam_file = Channel.fromPath(params.input_path + "/*.bam").toList()
        }
        else if (params.single_bam_type == "path"){
            bam_file =  Channel.fromPath(params.input_path).toList()
        }
    }
    else if( params.start == 'rebase' ){
        //Re-basecalling
        fast5 = Channel.fromPath(params.input_path +  "/fast5_*/*.fast5").toList()
        ReBasecallingGuppy(params.input_path, params.sample_id, fast5.sum{it.size()})
        fast5_files = ReBasecallingGuppy.out.map{fastq_files, fast5_files, all_files, bam_files, summary_file -> fast5_files}
        bam_files = ReBasecallingGuppy.out.map{fastq_files, fast5_files, all_files, bam_files, summary_file -> bam_files}
        summary_file = ReBasecallingGuppy.out.map{fastq_files, fast5_files, all_files, bam_files, summary_file -> summary_file}
    }
    else if( params.start == 'bam_remap' ){
        // Get fast5 and mapped bams from input folder
        bam_files = Channel.fromPath(params.input_path +  "/pass/*.bam").toList()
        summary_file = Channel.fromPath(params.input_path +  "/sequencing_summary.txt").toList()
    }
    else{
        error  """
            Invalid start mode: ${params.start}. This should be 
            bam (start from basecalled data),
            bam_remap (start from bam, but perform remapping with minimap2),
            bam_single (start from single bam without sequencing information),
            bam_single_remap (start from single bam without sequencing information and perform remapping),
            rebase (full re-basecalling)
        """
    }

    // Specific processes to sort and filter BAM based on start method.
    // Bams with Guppy summary_file output can have duplex deduplication while this is not possible for single BAM input
    if( params.start == 'bam_single' ||  params.start == 'bam_single_remap' ){
        // Index BAM
        Sambamba_Index(bam_file.map{bam_file -> [params.sample_id, bam_file]})

        // Filter for minimum readlength
        Sambamba_Filter_Condition(bam_file.combine(Sambamba_Index.out.map{sample_id, bai_file -> bai_file}))

        bam_file = Sambamba_Filter_Condition.out
    }
    else{
        // MergeSort BAMs
        Samtools_Merge(bam_files.map{bam_files -> [params.sample_id, bam_files]})

        // Index MergeSort BAM
        Sambamba_Index_Merge(Samtools_Merge.out)

        // Filter for minimum readlength
        Sambamba_Filter_Condition(
            Samtools_Merge.out
            .map{ sample_id, bam_file -> bam_file }
            .combine(Sambamba_Index_Merge.out.map{ sample_id, bai_file -> bai_file })
        )

        // Identify readpairs
        Duplex_PairsFromSummary(params.sample_id, summary_file)

        // Identify possible duplex reads from read pairs
        Duplex_FilterPairs(Duplex_PairsFromSummary.out, Sambamba_Filter_Condition.out)

        //Filter BAM for duplicate duplex read
        PICARD_FilterSamReads(Sambamba_Filter_Condition.out, Duplex_FilterPairs.out)

        //Index BAM file
        Sambamba_Index_Deduplex(PICARD_FilterSamReads.out.map{bam_file ->[params.sample_id, bam_file]})

        bam_file = PICARD_FilterSamReads.out.combine(
            Sambamba_Index_Deduplex.out.map{sample_id, bai_file -> bai_file}
        )

    }

    //Extract and re-map reads is start is _remap
    if( params.start == 'bam_remap' || params.start == 'bam_single_remap' ){
        // Extract FASTQ from BAM
        Samtools_Fastq(bam_file)

         // Re-map ROI fastq
        Minimap2(Samtools_Fastq.out)

        // Sort SAM to BAM
        Samtools_ViewSort(Minimap2.out.map{fastq, sam_file -> [params.sample_id, fastq , sam_file]})

        bam_file = Samtools_ViewSort.out.map{sample_id, rg_id, bam_file, bai_file -> [bam_file, bai_file]}

    }

    // General workflow for each start option from here on
    // Add readgroup to BAM
    Samtools_AddReplaceReadgroup(params.sample_id, bam_file)

    // Index readgroup BAM
    Sambamba_Index_ReadGroup(Samtools_AddReplaceReadgroup.out.map{bam_file -> [params.sample_id, bam_file]})

    bam_file = Samtools_AddReplaceReadgroup.out.combine(
        Sambamba_Index_ReadGroup.out.map{sample_id, bai_file -> bai_file})
        .map{bam_file, bai_file -> [params.sample_id, bam_file, bai_file]}

    // BED approach: variant calling and phasing based on a specific BED file with SNVs
    // Variant calling (BED approach)
    GATK_HaplotypeCaller_Bed(
        bam_file.map{sample_id, bam_file, bai_file -> [sample_id, bam_file, bai_file, params.ploidy]}
    )

    // Filter SNV only (BED approach)
    GATK_FilterSNV_Target_Bed(GATK_HaplotypeCaller_Bed.out)

    // Whatshapp polyphase (BED approach)
    Whatshap_Polyphase_Target_Bed(GATK_FilterSNV_Target_Bed.out)

    // bgzip and index VCF (BED approach)
    Tabix_Zip_Index_Bed(
        Whatshap_Polyphase_Target_Bed.out.map{sample_id, vcf_file, ploidy -> [sample_id, vcf_file]}
    )

    //Annotate Homopolymer VCF (BED approach)
    Bcftools_Annotate_Bed(
        Tabix_Zip_Index_Bed.out.map{sample_id, vcf_file, vcf_file_index -> [vcf_file, vcf_file_index]}
    )

    //Index Homopolymer annotated VCF file (BED approach)
    Tabix_Zip_Index_Bcftools_Bed(Bcftools_Annotate_Bed.out.map{vcf_file -> [params.sample_id, vcf_file]})

    //Filter VCF (BED approach)
    GATK_VariantFiltration_Bed(Tabix_Zip_Index_Bcftools_Bed.out)

    // Whatshapp haplotag (BED approach)
    Whatshap_Haplotag_Target_Bed(
        GATK_HaplotypeCaller_Bed.out
        .map{sample_id, bam_file, bai_file, vcf_file, vcf_index, ploidy -> [sample_id, bam_file, bai_file, ploidy]}
        .join(GATK_VariantFiltration_Bed.out)
    )

    // Index BAM file and publish (BED approach)
    Sambamba_Index_Target_Bed(Whatshap_Haplotag_Target_Bed.out.map{bam_file -> [params.sample_id, bam_file]})

    // Get correct phasegroup (BED approach)
    GetPhaseSet_Bed(GATK_VariantFiltration_Bed.out)

    // Split BAM into single haplotypes (BED approach)
    Sambamba_Filter_Haplotype_Phaseset_Bed(
        Whatshap_Haplotag_Target_Bed.out
        .combine(
            Sambamba_Index_Target_Bed.out.map{sample_id, bai_file -> bai_file}
        )
        .combine(ploidy_list)
        .combine(GetPhaseSet_Bed.out)
    )

    //Clair3 calling on haplotype BAMs (BED approach)
    Clair3_Bed(Sambamba_Filter_Haplotype_Phaseset_Bed.out)

    // Annotate Clair3 VCF (BED approach)
    Bcftools_Annotate_Clair3_Bed(Clair3_Bed.out)

    //Index Homopolymer annotated VCF file (BED approach)
    Tabix_Zip_Index_Bcftools_Clair3_Bed(Bcftools_Annotate_Clair3_Bed.out.map{vcf_file -> [params.sample_id, vcf_file]})

    //Filter VCF (BED approach)
    GATK_VariantFiltration_Clair3_Bed(Tabix_Zip_Index_Bcftools_Clair3_Bed.out)

    //Sniffles SV variant calling on haplotype BAMs (BED approach)
    Sniffles2_Bed(Sambamba_Filter_Haplotype_Phaseset_Bed.out)

    // REGION approach: variant calling and phasing on a specific region of interest
    // Variant calling (REGION approach)
    GATK_HaplotypeCaller_Region(
        bam_file.map{sample_id, bam_file, bai_file -> [sample_id, bam_file, bai_file, params.ploidy]}
    )

    //Filter SNV only (REGION approach)
    GATK_FilterSNV_Target_Region(GATK_HaplotypeCaller_Region.out)

    // Whatshapp polyphase region (REGION approach)
    Whatshap_Polyphase_Target_Region(GATK_FilterSNV_Target_Region.out)

    // bgzip and index VCF (REGION approach)
    Tabix_Zip_Index_Region(
        Whatshap_Polyphase_Target_Region.out.map{sample_id, vcf_file, ploidy -> [sample_id, vcf_file]}
    )

    //Annotate Homopolymer VCF (REGION approach)
    Bcftools_Annotate_Region(
        Tabix_Zip_Index_Region.out.map{sample_id, vcf_file, vcf_file_index -> [vcf_file, vcf_file_index]}
    )

    //Index Homopolymer annotated VCF file (REGION approach)
    Tabix_Zip_Index_Bcftools_Region(Bcftools_Annotate_Region.out.map{vcf_file -> [params.sample_id, vcf_file]})

    //Filter VCF (REGION approach)
    GATK_VariantFiltration_Region(Tabix_Zip_Index_Bcftools_Region.out)

    // Whatshapp haplotag (REGION approach)
    Whatshap_Haplotag_Target_Region(
        GATK_HaplotypeCaller_Region.out
        .map{sample_id, bam_file, bai_file, vcf_file, vcf_index, ploidy -> [sample_id, bam_file, bai_file, ploidy]}
        .join(GATK_VariantFiltration_Region.out)
    )

    // Index BAM file and publish (REGION approach)
    Sambamba_Index_Target_Region(Whatshap_Haplotag_Target_Region.out.map{bam_file -> [params.sample_id, bam_file]})

    // Get correct phasegroup (REGION approach)
    GetPhaseSet_Region(GATK_VariantFiltration_Region.out)

    // Split BAM into single haplotypes (REGION approach)
    Sambamba_Filter_Haplotype_Phaseset_Region(
        Whatshap_Haplotag_Target_Region.out
        .combine(
            Sambamba_Index_Target_Region.out.map{sample_id, bai_file -> bai_file}
            )
       .combine(ploidy_list)
       .combine(GetPhaseSet_Region.out)
    )

    //Clair3 calling on haplotype BAMs (REGION approach)
    Clair3_Region(Sambamba_Filter_Haplotype_Phaseset_Region.out)

    // Annotate Clair3 VCF (REGION approach)
    Bcftools_Annotate_Clair3_Region(Clair3_Region.out)

    //Index Homopolymer annotated VCF file (REGION approach)
    Tabix_Zip_Index_Bcftools_Clair3_Region(Bcftools_Annotate_Clair3_Region.out.map{vcf_file -> [params.sample_id, vcf_file]})

    //Filter VCF (REGION approach)
    GATK_VariantFiltration_Clair3_Region(Tabix_Zip_Index_Bcftools_Clair3_Region.out)

    //Sniffles SV variant calling on haplotype BAMs (REGION approach)
    Sniffles2_Region(Sambamba_Filter_Haplotype_Phaseset_Region.out)

    // QC stats
    PICARD_CollectMultipleMetrics(bam_file)
    PICARD_CollectWgsMetrics(bam_file)
    MultiQC(analysis_id, Channel.empty().mix(
        PICARD_CollectMultipleMetrics.out,
        PICARD_CollectWgsMetrics.out
    ).collect())

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
        def subject = "SMA Workflow Successful: ${analysis_id}"
        sendMail(
            to: params.email.trim(),
            subject: subject,
            body: email_html,
        )

    } else {
        def subject = "SMA Workflow Failed: ${analysis_id}"
        sendMail(to: params.email.trim(), subject: subject, body: email_html)
    }
}
