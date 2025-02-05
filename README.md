# HapSMA
Workflow HapSMA to process long-read sequencing data for the SMA locus.  
HapSMA has primarily been developed to process ONT sequencing data (R9.4.1 pore and chemistry).  
However, we also provide information to process PacBio and ONT R10 data using HapSMA.  
Use of HapSMA with PacBio data is not recommended; we recommend to use [Paraphase](https://github.com/PacificBiosciences/paraphase) instead.  

Note that HapSMA has been developed and optimized (settings and resources) for the Utrecht HPC environment (Linux AMD64, Slurm). Although we aimed for easy deployment of HapSMA, we can not guarentee deployment on your own system.  

# Requirements
HapSMA is developed, optimized, and tested on Linux operating system with AMD64 processors.  
Running the workflow on different operation systems and/or processor architecture should be possible, but not tested.  

Dependencies/ required software:
* Singularity   (tested version 1.3.1)
* OpenJDK       (tested version jdk21.0.2)
* Nextflow      (tested version 23.10.0)
* wget		(tested version 1.19.5)

OpenJDK and Nextflow can be installed executing the following command: 
```bash
sh install.sh
``` 
### Minimal requirements compute resources (full analysis):
cpu = 10  
memory = 48GB  
tmpspace = 64GB  
### Minimal requirements compute resources (demo data analysis):
cpu = 1  
memory = 8GB  
tmpspace = 16GB  
#### *Note that the total size of the containers used in HapSMA is currenly ~5Gb.*

# 1) Analyzing demo data
We've included a demo dataset to test the workflow.  
This demo dataset contains ONT sequencing data from sample HG02071 that was generated as part of the [Human PanGenomics Project](https://registry.opendata.aws/hpgp-data) published in [Liao et al. 2023, Nature]( https://doi.org/10.1038/s41586-023-05896-x).  

Download and unpack the demo dataset (within the root folder of the Git repository checkout folder):
```
wget  https://zenodo.org/records/14762937/files/demo_data_HapSMA.tar.gz
mkdir ./demodata && tar -xzvf demo_data_HapSMA.tar.gz --directory ./demodata
```
Demo data can be analyzed executing the following command in which \<email\> should be replaced by the user email-address:  
``` 
sh run_demo.sh <email>
```
Data processing will take ~75 minutes.  
A successfull analysis will result in an email with subject: "SMA Workflow Successful".    
Processed data will be stored in folder `demo_analysis/output`.  

We have included output data (BAM files and VCF files) within the `demodata/results/` folder that can be used to compare results (i.e with bcftools isec for comparisons of VCFs).  
Note that small differences can occur due to the use of different compute environments.


# 2) Analyzing full datasets

Although several options are available to start HapSMA we strongly advise to always provide a single BAM file as input and always perform re-mapping (option __bam_single_remap__).  
To speed up the HapSMA analysis, we recommend to use a 'chromosome of interest' filtered BAM (i.e. chr5) as input.  
Other options (see below in paragraph 3) were used for processing the data in the HapSMA manuscript but are __not recommended__ for general use. 
## Configure paths before use (needed for both ONT and Pacbio)
Please configure the following parameters in SMA.config to your local settings:
<pre>
  genome_fasta          	full path to reference genome fasta (.fasta/.fa/.fna). note that  the reference genome needs an index (.fai) and a dictionary (.dict).
  calling_target_bed    	full path to "position specific" GATK ploidy aware variant calling that will be used in phasing (.bed).
  calling_target_region 	region of interest for GATK ploidy aware variant calling that will be used in phasing (chr:start-stop, i.e. chr5:71274893-71447410).
  phaseset_region		region of interest to determine phaseset which will be used to make haplotag specific BAMs (chr:start-stop, i.e. chr5:71392465-71409463).
  homopolymer_bed       	full path to homopolymer region of reference genome that will be used to annotate VCFs (.bed).
</pre>
For more information of the reference genome indexing, see paragraph 4.
See [ManuscriptSMNGeneConversion](https://github.com/UMCUGenetics/ManuscriptSMNGeneConversion) to find an example of calling_target_bed (paraphase_SNPs_UCSC_liftover_T2T_CHM13_manual_SNPs_2_sorted_20b_22b.bed) and instructions how to make a homopolymer_bed file.  

## Running SMA workflow ONT data 
We recommend starting HapSMA using a single BAM file as input.  
The default workflow (R9.4.1) can be started with command:

```bash
workflow_path="/change/to/repository/path"
export NXF_JAVA_HOME="${workflow_path}/tools/java/jdk"

$workflow_path/tools/nextflow/nextflow run $workflow_path/SMA.nf \
    -c $workflow_path/SMA.config \
    --input_path <input_path_to_bam> \
    --outdir <output_dir_path> \
    --start bam_single_remap \
    --single_bam_type path \
    --ploidy <ploidy> \
    --sample_id <sampleID> \
    --email <email>
```
* \<input_path_to_bam> full path to the input BAM file. 
* \<output_dir_path> output folder path.  
* \<ploidy> copynumber of SMN1 and SMN2 combined (integer). This should be provided by the user and can be determined with orthogonal methods such as MLPA.  
* \<sampleID> ID of the sample.  
* \<email> email address of the user.  

Optionally other ONT models can be used (including R10) by adding --clair3model to the command above:
```
--clair3model /opt/models/<model> 
```
Current implementation supports these models:  
<pre>
r941_prom_hac_g238
r941_prom_hac_g360+g422
r941_prom_sup_g5014         (default)
r1041_e82_400bps_hac_v430
r1041_e82_400bps_hac_v500
r1041_e82_400bps_sup_v430
r1041_e82_400bps_sup_v500
</pre>

#### Computational efficiency  
Data processing time highly dependent on sequence coverage, data quality, and copynumber.  
Analysis of a chromosome 5 filtered WGS BAM file (~30X) will take approximately 4 hours using default resources (cpu = 10, memory = 48GB).


## Running SMA workflow PacBio data
We recommend starting HapSMA using a single BAM file as input.

The workflow can be started with command:
```bash
workflow_path="/change/to/repository/path"
export NXF_JAVA_HOME="${workflow_path}/tools/java/jdk"

$workflow_path/tools/nextflow/nextflow run $workflow_path/SMA.nf \
    -c $workflow_path/SMA.config \
    -c $workflow_path/SMA_Pacbio.config \
    --input_path <input_path_to_bam> \
    --outdir <output_dir_path> \
    --start bam_single_remap \
    --single_bam_type path \
    --ploidy <ploidy> \
    --sample_id <sampleID> \
    --email <email>
```
* \<input_path_to_bam> full path to the input BAM file. 
* \<output_dir_path> output folder path.  
* \<ploidy> copynumber of SMN1 and SMN2 combined (integer). This should be provided by the user and can be determined with orthogonal methods such as MLPA.  
* \<sampleID> ID of the sample.  
* \<email> email address of the user.  

Optionally other Pacbio models can be used by adding --clair3model to the command above:
```
--clair3model /opt/models/<model> 
```
Current implementation supports these models:  
<pre>
hifi
hifi_revio      (default)
hifi_sequal2
</pre>

#### Computational efficiency
Data processing time highly dependent on sequence coverage, data quality, and copynumber.
Analysis of a chromosome 5 filtered WGS BAM file (~30X) will take approximately 1 hour using default resources (cpu = 10, memory = 48GB).

# 3) Manuscript specific settings and options

Full data analysis is recommended starting from a single BAM file using (both for ONT and Pacbio), as described in paragraph 2:
```
--input_path <input_path_to_bam> --start bam_single_remap --single_bam_type path
```
For ONT data we provided an additional start option based on raw sequencing data (including re-basecalling) and Guppy output folders.

### HapSMA including re-basecalling using Guppy
HapSMA has support for re-basecalling raw sequencing data (FAST5) using Guppy software (tested v6.1.2).

* Rebase(calling) requires local install of Guppy 6.1.2.  
Change the following Guppy specific parameter in SMA.config:
<pre>
  genome_mapping_index      full path to reference genome minimap2 index (.mmi).
  guppy_basecaller_path     full path to guppy_basecaller executable.
  guppy_basecaller_config   full path to basecalling model file to be used (.cfg).
</pre>

For more information of the .mmi index, see paragraph 4.

Re-basecalling with Guppy requires the use of GPUs. Make sure setting in SMA.config are configured to correct settings. As these settings are highly dependent on the compute environment, we do not provide additional support.  

HapSMA including re-basecalling can be started using the following command:
```bash
workflow_path="/change/to/repository/path"
export NXF_JAVA_HOME="${workflow_path}/tools/java/jdk"

$workflow_path/tools/nextflow/nextflow run $workflow_path/SMA.nf \
    -c $workflow_path/SMA.config \
    --input_path <input_path> \
    --outdir <output_dir_path> \
    --start rebase \
    --ploidy <ploidy> \
    --sample_id <sampleID> \
    --email <email>
```

* \<input_path> full path to the sequence output folder containing fast5_pass/ and/or fast5_fail/ folders in which the FAST5 files are located.  
* \<output_dir_path> output folder path.  
* \<ploidy> copynumber of SMN1 and SMN2 combined (integer). This should be provided by the user and can be determined with orthogonal methods such as MLPA.  
* \<sampleID> ID of the sample.  
* \<email> email address of the user.  

### HapSMA starting from Guppy output folder
Optionally, HapSMA can also be started based on the Guppy (v6.1.2) output folder containing BAM files.
For this, two start options are available __bam__ or __bam_remap__, with the difference that __bam_remap__ will remap the reads to the reference genome provide in SMA.config. We advise to always perform remapping.  

```bash
workflow_path="/change/to/repository/path"
export NXF_JAVA_HOME="${workflow_path}/tools/java/jdk"

$workflow_path/tools/nextflow/nextflow run $workflow_path/SMA.nf \
    -c $workflow_path/SMA.config \
    --input_path <input_path> \
    --outdir <output_dir_path> \
    --start <bam/bam_remap> \
    --ploidy <ploidy> \
    --sample_id <sampleID> \
    --email <email>
```
* \<input_path> full path to Guppy output folder containing BAM files in the pass/ folder and sequencing_summary.txt in the root folder.  
* \<output_dir_path> output folder path.  
* \<ploidy> copynumber of SMN1 and SMN2 combined (integer). This should be provided by the user and can be determined with orthogonal methods such as MLPA.  
* \<sampleID> ID of the sample.  
* \<email> email address of the user.  

# 4) How to index the reference genome.
The reference genome in SMA.config must be indexed using Samtools, Picard and (optionally) Minimap2.  
Make sure that the index files are present in the same folder as the reference genome.
### .fai with samtools (tested version 1.15)
```bash
samtools faidx <path_to_reference_fasta>
```
### .dict with Picard (tested version 3.0.0)
```bash
picard CreateSequenceDictionary -R <path_to_reference_fasta> -O <path_to_reference_fasta>.dict
```
### .mmi with minimap2 (tested version 2.26)
*Only needed if rebasecalling with Guppy is performed*
```bash
minimap2 -d <path_to_reference_fasta>.mmi <path_to_reference_fasta>
```
# 5) Utrecht specific scripts
SMA_umcu.config, run_nextflow_sma_umcu_ont.sh, run_nextflow_sma_umcu_pacbio.sh are specifically made to run HapSMA on the Utrecht HPC infrastructure. Please do not use these, although they could serve as a template for your specific compute environment.  
