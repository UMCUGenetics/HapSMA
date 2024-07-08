# NextflowSMA
Workflow SMA for Oxford Nanopore Technologies sequencing data

Requirements general use:
* Minimal resource requirement for current SMA.config is cpu = 10 and memory = 48GB. These can be lowered in SMA.config, but might result in longer analysis time.
* Rebase(calling) method using Guppy needs to be run on GPU compute node with sufficient resources for the non-gpu part of the workflow (cpu = 10, memory = 48GB). Resources can be lowered in SMA.config, but might result in longer analysis time.
* Guppy needs to be installed locally.
* Singularity(/Docker) needs to be installed on the system to run the workflow. Testing has been performed using Singularity 1.3.1.
* OpenJDK and nextflow needs to be installed (see install.sh script). Workflow has been tested with nextflow 23.10.0 and jdk21.0.2

Note:
* Workflow testing has been performed on UMC Utrecht HPC enviroment using SMA.config + SMA_umcu.config in wrapper run_nextflow_sma_umcu.sh.
* Worfklow testing has only been performed using R9.4.1 sequencing data with guppy_6.1.2 basecalling.
* General use of the workflow is described below using SMA.config, although some configuration might be needed depending on your local infrastructure.
* Reference genome needs to be indexed. For more details see below in section "How to index the reference genome".

## Install OpenJDK and Nextflow.
The `install.sh` bash script can be used the install the OpenJDK and Nextflow versions used for this workflow.\
The scripts assumes to be run in the root folder of this repository and will create a tools folder in which both tools will be installed.

```bash
sh install.sh
```

## Configure paths before use
SMA.config:
<pre>
  genome_fasta          	full path to reference genome fasta (.fasta/.fa/.fna). note that  the reference genome needs an index (.fai) and a dictionary (.dict)
  calling_target_bed    	full path to "position specific" GATK ploidy aware variant calling that will be used in phasing (.bed)
  calling_target_region 	region of interest for GATK ploidy aware variant calling that will be used in phasing (chr:start-stop, i.e. chr5:71274893-71447410)
  phaseset_region		region of interest to determine phaseset which will be used to make haplotag specific BAMs (chr:start-stop, i.e. chr5:71392465-71409463)
  homopolymer_bed       	full path to homopolymer region of reference genome that will be used to annotate VCFs (.bed)

  Only needed in case of the rebase(calling) method:
  genome_mapping_index          full path to reference genome minimap2 index (.mmi)
  guppy_basecaller_path 	full path to guppy_basecaller executable
  guppy_basecaller_config 	full path to basecalling model file to be used (.cfg)
</pre>

## Running SMA workflow
```bash
workflow_path='/change/to/repository/path'
export NXF_JAVA_HOME='$workflow_path/tools/java/jdk'

$workflow_path/tools/nextflow run $workflow_path/SMA.nf -c $workflow_path/SMA.config --input_path <input_path> --outdir <output_dir_path> --start <start> --ploidy <ploidy> --email <email> 
```

### --start and --input_path

NextflowSMA has three start options (__rebase__, __bam__, __bam_single__) which all require input folders containing different structures and underlying files (see below).

Optionally the suffix ___remap__ can be added to __bam__ and __bam_single__, this will enable remapping of the reads to the reference genome provided in SMA.config.\
To prevent downstream issues in variant calling we would advise to always include ___remap__ unless it is certain that the reference genome in SMA.config has also been used for mappping reads in the input BAM.


  * __rebase__
    * start from raw sequencing data (MinKNOW) output containing the FAST5 files
    * input_path = full path to the sequence output folder containing fast5_pass/ and/or fast5_fail/ folders in which the FAST5 files are located.
   
  * __bam__
    * start from BAM files within the Guppy output folder
    * input_path = full path to Guppy output folder containing BAM files in the pass/ folder and sequencing_summary.txt in the root folder
    
  * __bam_remap__
    * start from BAM files within the Guppy output folder and perform remapping
    * input_path = full path to Guppy output folder containing BAM files in the pass/ folder and sequencing_summary.txt in the root folder
     
  * __bam_single__
    * start from single bam file 
    * input_path = full path to folder containing (only) one BAM file
    
  * __bam_single_remap__
    * start from single bam file and perform remapping
    * input_path = full path to folder containing (only) one BAM file
     
    
### --ploidy
* Estimated copy number of SMN1 + SMN2 (integer)

## How to index the reference genome.
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
(for rebasecalling only) .mmi using minimap2 -d (tested version 2.26)
```bash
minimap2 -d <path_to_reference_fasta>.mmi <path_to_reference_fasta>
```

# UMC Utrecht specific files
SMA_umcu.config and run_nextflow_sma_umcu.sh are custom scripts to run the workflow on the UMC Utrecht HPC infrastructure.
Please do no use these, although they could serve as a template for your specific compute environment.
