# HapSMA
Workflow SMA to process long-read sequencing data for the SMA locus.  

HapSMA has primarily been developped to process ONT sequencing data (R9.4.1 pore and chemistry).
However, we also provide information to process PacBio and ONT R10 data using HapSMA. 

Note that HapSMA has been developped and optimized (settings and resources) for the UMC Utrecht HPC enviroment (Linux AMD64, Slurm). 
Although we aimed to make HapSMA with minimal dependencies, deployment on your own system might still require specific changes.

# Requirements

HapSMA is developed, optimized, and tested on Linux operating system with ARM64 processors.  
Running the workflow on different operation systems and processor architecture should be possible, but not supported.

Required software"
* Singularity   (tested version 1.3.1)
* OpenJDK       (tested version jdk21.0.2)
* Nextflow      (tested version 23.10.0) 

OpenJDK and Nextflow can be installed excecuting the following command in repo folder: 
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

#### *Note that de images used in HapSMA require ~4Gb of storage space*


# 1) Analysing demo data
We've included a demo dataset to test the workflow.

Download and unpack the demo dataset within the root folder of the Git repo checkout
```
wget  <link> 
tar -xzvf <datafile>.tar.gz
```

Demodata can be analysed excecuting the following command
``` 
sh run_demo.sh <email>
```
in which \<email\> should be replaced by the user email-adress

__Note:__  *The current setup of run_demo.sh is indended to be excecuted the *__home folder__* of the user*  
*Please modify singularity profile within SMA_demodata.config: i.e. replace $HOME bind option for runOptions with the desired work path.*


Data processing will take ~30 minutes (depending on internet speed connection).  

A succesfull analysis will result in a email with subject: "SMA Workflow Successful"  
Processed data will be stored /demo_analysis/output

# 2) Analysing full datasets

## __Note:__  
Althoug several options are available to start HapSMA we strongly advice to always provide a single BAM file as input, and always perform re-mapping (option __bam_single_remap__).  
Other options (see below in section: manuscript specific) were used for processing the data in the HapSMA manuscript, but are __not recommended__ for general use. 
## Configure paths before use (needed for both ONT and Pacbio)
Please change the following parameters in SMA.config:

<pre>
  genome_fasta          	full path to reference genome fasta (.fasta/.fa/.fna). note that  the reference genome needs an index (.fai) and a dictionary (.dict)
  calling_target_bed    	full path to "position specific" GATK ploidy aware variant calling that will be used in phasing (.bed)
  calling_target_region 	region of interest for GATK ploidy aware variant calling that will be used in phasing (chr:start-stop, i.e. chr5:71274893-71447410)
  phaseset_region		    region of interest to determine phaseset which will be used to make haplotag specific BAMs (chr:start-stop, i.e. chr5:71392465-71409463)
  homopolymer_bed       	full path to homopolymer region of reference genome that will be used to annotate VCFs (.bed)
</pre>

For more information of the reference genome indexing, see paragraph 4.


## Running SMA workflow ONT data 
We recommend to start HapSMA using a single BAM file as input.  
The default workflow (R9.4.1) can be started with command:

```bash
workflow_path='/change/to/repository/path'
export NXF_JAVA_HOME='$workflow_path/tools/java/jdk'

$workflow_path/tools/nextflow run $workflow_path/SMA.nf -c $workflow_path/SMA.config --input_path <input_path_to_bam> --outdir <output_dir_path> --start bam_single_remap --single_bam_type path --ploidy <ploidy> --email <email>
```
* \<input_path_to_bam> full path to the input BAM file. 
* \<output_dir_path> output folder path
* \<ploidy> estimated copynumber of SMN1 and SMN2 combined (integer). This estimation is currently not supported within the workflow and should be provided by the user.  
* \<email> email adress of the user


Optionally other ONT models can be used (including R10) by adding --clair3model to the command above
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


Data processing time is dependent on the original sequence coverage.
Typically processing 


## Running SMA workflow PacBio data
We recommend to start HapSMA using a single BAM file as input

The workflow can be started with command:
```bash
workflow_path='/change/to/repository/path'
export NXF_JAVA_HOME='$workflow_path/tools/java/jdk'

$workflow_path/tools/nextflow run $workflow_path/SMA.nf -c $workflow_path/SMA.config -c $workflow_path/SMA_Pacbio.config --input_path <input_path_to_bam> --outdir <output_dir_path> --start bam_single_remap --single_bam_type path --ploidy <ploidy> --email <email>
```
* \<input_path_to_bam> full path to the input BAM file. 
* \<output_dir_path> output folder path
* \<ploidy> estimated copynumber of SMN1 and SMN2 combined (integer). This estimation is currently not supported within the workflow and should be provided by the user.  
* \<email> email adress of the user


Optionally other Pacbio models can be used by adding --clair3model to the command above
```
--clair3model /opt/models/<model> 
```
Current implementation supports these models:  
<pre>
hifi
hifi_revio      (default)
hifi_sequal2
</pre>

Data processing time is dependent on the original sequence coverage.
Typically processing 


# 3) Manuscript specific parameters

Full data analysis is recommended to start from a single BAM file using (both for ONT and Pacbio)
```
--input_path <input_path_to_bam> --start bam_single_remap --single_bam_type path
```

For ONT data we provided additional start based on raw-sequencing data (including re-basecalling) and Guppy output folders.

### HapSMA including re-basecalling using Guppy

HapSMA has support for re-basecalling raw sequencing data (FAST5) using Guppy software (tested v6.1.2)

* Rebase(calling) requires local install of Guppy 6.1.2. Specific Guppy paths should be included in SMA.config:
<pre>
  genome_mapping_index      full path to reference genome minimap2 index (.mmi)
  guppy_basecaller_path     full path to guppy_basecaller executable
  guppy_basecaller_config   full path to basecalling model file to be used (.cfg)
</pre>

For more information of the .mmi index, see paragraph 4.

Re-basecalling with Guppy requires GPUs. Make sure setting in SMA.config are configured to correct settings.
As these settings are highly dependent on the compture enviroment, we can not provide additional support.

HapSMA including re-basecalling can be started using the following command:
```bash
workflow_path='/change/to/repository/path'
export NXF_JAVA_HOME='$workflow_path/tools/java/jdk'

$workflow_path/tools/nextflow run $workflow_path/SMA.nf -c $workflow_path/SMA.config --input_path <input_path> --outdir <output_dir_path> --start rebase --ploidy <ploidy> --email <email>
```

* \<input_path> full path to the sequence output folder containing fast5_pass/ and/or fast5_fail/ folders in which the FAST5 files are located.
* \<output_dir_path> output folder path
* \<ploidy> estimated copynumber of SMN1 and SMN2 combined (integer). This estimation is currently not supported within the workflow and should be provided by the user.  
* \<email> email adress of the user

### HapSMA starting from Guppy folder

Optionally, HapSMA also can be started based on the Guppy (v6.1.2) output folder containing BAM files.
For this, two start options are available __bam__ or __bam_remap__, with the difference that __bam_remap__ with remap the reads to the reference genome provide in SMA.config. We advice to always perform remapping.

```bash
workflow_path='/change/to/repository/path'
export NXF_JAVA_HOME='$workflow_path/tools/java/jdk'

$workflow_path/tools/nextflow run $workflow_path/SMA.nf -c $workflow_path/SMA.config --input_path <input_path> --outdir <output_dir_path> --start <bam/bam_remap> --ploidy <ploidy> --email <email>
```
* \<input_path> full path to Guppy output folder containing BAM files in the pass/ folder and sequencing_summary.txt in the root folder
* \<output_dir_path> output folder path
* \<ploidy> estimated copynumber of SMN1 and SMN2 combined (integer). This estimation is currently not supported within the workflow and should be provided by the user.  
* \<email> email adress of the user


# 4) How to index the reference genome.
The reference genome in SMA.config must be indexed using Samtools, Picard and (optionally) Minimap2.\
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

# 5) UMC Utrecht specific scripts

SMA_umcu.config, run_nextflow_sma_umcu_ont.sh, run_nextflow_sma_umcu_pacbio.sh are specifically made to run HapSMA on the UMC Utrecht HPC infrastructure.
Please do no use these, although they could serve as a template for your specific compute environment.




