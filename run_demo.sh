workflow_path=$PWD
EMAIL=$1

if [ ! -d demo_analysis ]; then
  mkdir demo_analysis
fi

cd demo_analysis

export NXF_HOME=$workflow_path/demo_analysis/
export NXF_JAVA_HOME=$workflow_path/tools/java/jdk
export NXF_APPTAINER_CACHEDIR=$workflow_path/demo_analysis/
export SINGULARITY_CACHEDIR=$TMPDIR

$workflow_path/tools/nextflow/nextflow run \
    $workflow_path/SMA.nf \
    -c $workflow_path/SMA.config \
    -c $workflow_path/SMA_demodata.config \
    --input_path $workflow_path/demodata/test_ont_sub.bam \
    --genome_fasta $workflow_path/demodata/chr5.fa \
    --calling_target_bed $workflow_path/demodata/paraphase_SNPs_UCSC_liftover_T2T_CHM13.bed \
    --homopolymer_bed $workflow_path/demodata/hs1_hm_20a_22a_3homopolymer_chr5demo.bed \
    --outdir $workflow_path/demo_analysis/output \
    --calling_target_region "chr5:71274893-71447410" \
    --phaseset_region "chr5:71392465-71409463" \
    --start bam_single_remap \
    --ploidy 3 \
    --sample_id test \
    --single_bam_type path \
    --workflowpath $workflow_path \
    --email $EMAIL \
    -profile test \
    -resume 
