# RaptorQuant 
A pipeline developed for flawless downstream analysis of bulk RNAseq data. It is primarily designed for people with no major IT skills, as it requires only a few basic edits on the user’s part.

Based on your preferences, the pipeline can:
- Analyze the quality of your data via FASTQC and MULTIQC.
- Trim your data with Trim Galore!
- Compute the quantity of transcripts present in your data with Salmon.
- Create a large table containing results from Salmon for every sample and search for desired transcripts.
 ___________________

# How to do it
Firstly clone the repository via git:

	git clone https://github.com/KowalskiBio/RaptorQuant

## 1) Get your data
- **If you want to download the data**: Provide URLs from ENA in the prepared file located in _./configs/links.txt_ (two examples are already present in the file). Please ensure that the data is in .gz format. Supposing you are in the RaptorQuant directory, run the following commands:

      chmod +x Download.sh
      ./Download.sh

- **If you provide your own data**: Your files need to be in .fastq.gz or .fq.gz format for downstream analysis. If trimming is required, place your data in _./data/raw_fastq._ If no trimming is required, place your data in _./data/trimmed_fastq._ The pipeline starts from this directory.

## 2) Run the pipeline
To run the pipeline, enter the following commands, assuming you are in the RaptorQuant directory:

      chmod +x ./scripts/*.sh
      chmod +x Run.sh
      ./Run.sh

### Options in the workflow
You will be asked several questions during the process. The workflow changes depending on your answers. Below are the defined options:
- **Quality analysis with FASTQC/MULTIQC** - Check the quality of your data. Results are stored in the _./output_ directory. FASTQC provides individual results, while MULTIQC provides combined results. Two rounds of quality checks are performed (if trimming is done), ensuring that the trimmed data is also assessed.
- **Trimming** -  Your raw data could be trimmed with Trim Galore! The pipeline is set up to do this automatically, if you select so. The trimmed data will be used for further analysis.
- **Salmon** - You will be asked to choose between Ensembl and RefSeq data annotation, as these two differ. Both annotations are created with k=23. Information about the annotations used is in _./data/salmon/About.txt_. Auxiliary information about each Salmon run is included in the individual result files.
- **Editing results** – Salmon outputs individual sample results. To analyze your results and search for the transcript(s) of your choice, enter the exact transcript ID. Note:
  - If you selected Ensembl as the annotation, enter the Ensembl transcript ID.
  - If you selected RefSeq, enter the correct RefSeq transcript ID.

- Additional information about specific annotation can be found here:
	- https://www.ncbi.nlm.nih.gov/books/NBK50679/ for RefSeq
 	- https://www.ensembl.org/info/genome/genebuild/index.html for Ensembl.

# Results
Generally, everything produced by this pipeline (except trimmed data) can be found in the ./output directory. Results from Salmon specifically are located in _./output/salmon_results_. The results for each sample are stored individually. However, if the user chooses to analyze the data, which is the final step of the pipeline, and provides a transcript ID, two additional files are created during the workflow:
1) combined_results.tsv – A merged results file containing data from every sample processed in the run. The file is organized as a table with several columns, similar to the standard quant.sf file from Salmon. These columns include the name of the sample, transcript IDs, TPM (transcripts per million), and NumReads (number of reads).
2) filtered_results.tsv – A filtered results file displaying only the IDs provided by the user for clarity. This file has the same columns as combined_results.tsv.

An example of both files can be found in the _./output/salmon_results_ directory.


**Happy quanting!**




![Diagram1 drawio](https://github.com/user-attachments/assets/0431422d-071b-4705-8f4c-8d3b3b6a8235)
