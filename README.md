# NWFSC Vermilion Sunset Rockfish Project  <img src="https://github.com/anita-wray/vermilion_sunset_gtseq/assets/82060951/92b658c9-0002-4587-b02d-a86940768350" width="300" height="400" align="right">


## Objective:

The primary objective was to conduct a genomic analysis to distinguish the vermilion rockfish stock along the west coast from sunset rockfish using tissue samples previously collected during fishery-independent resource surveys. Specifically, we (1) used high-throughput sequencing technologies to identify single nucleotide polymorphisms (SNPs) which produced an assay that definitively separates the two species, (2) applied this SNP panel to over 27 thousand samples and finally (3) identified species-specific demographic and biological differences.

Species ID utilized Rubias, which was altered to allow for species specific calls. SNP panel was built by Gary Longo. ~27,000 fish were sequenced by GTSeek.


## Methods:

### 1. [Genotyping](https://github.com/GTseq/GTseq-Pipeline)
Run [Nate Campbell's GT-seq genotyper](https://github.com/GTseq/GTseq-Pipeline) to produce a .csv file with genotypes and summary statistics for all samples. I just ran GTseq_Genotyper_v3.pl and GTseq_GenoCompile_v3.pl.

### 2. Species Identification using Rubias
Run Rubias with a reference panel of known individuals to identify samples as either Vermilion or Sunset Rockfish. [Script here](https://github.com/anita-wray/vermilion_sunset_gtseq/blob/main/RUBIAS/VMRF_rubias_PCA.R)

This script needs 4 inputs:
1. a common loci RDS <- common_loci_path
2. a reference rockfish df for input to Rubias <- rf_reference_df_sans_SVH_path
3. a reference rockfish genind for PCA plots <- rf_GTseq_panel_genind_path
4. a excel file (not csv) with the 'unknown' samples <- rf_GTs_path
5. (optional) a non-reference rockfish genind to visualize flagged species with other rockfish species <- otro_rf_spp_sample_ID_path

### 3. Biological Data merging


### 4. Statistics and Graphics
Code for all analyses and figures for the manuscript are included in [this folder](https://github.com/anita-wray/vermilion_sunset_gtseq/tree/main/Figures). Major figure results and included below.

## Major Results:
- Vermilion rockfish were identified throughout the sampling region, from Hood Canal, WA to the US/Mexico border. In contrast, no sunset rockfish were encountered north of Point Arena, CA (38.91° N).
- Vermilion rockfish were caught at significantly shallower depths than sunset, although there was substantial overlap between the two species.
- Both vermilion and sunset rockfish demonstrated sexually dimorphic length-weight relationships, with females of both species generally heavier at longer lengths than males.
- Sunset rockfish of both sexes tended to be heavier at longer lengths than their vermilion rockfish counterparts.
- Both male and female sunset rockfish grew faster and reached substantially larger values of L∞ than their vermilion counterparts.
- Among all individuals captured, the mean length of sunset rockfish was significantly longer than vermilion rockfish.
- The weight and length of both species increased with depth, suggesting both species undergo ontogenetic migration into deeper waters.



