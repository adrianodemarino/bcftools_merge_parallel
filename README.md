---

# Parallel BCFtools Merge Script

## Overview

This script provides a parallelized approach to merging VCF/BCF files using BCFtools. It's especially beneficial for merging large datasets, efficiently splitting the task across multiple cores and thereby significantly reducing the overall time required for merging.

## Performance

Traditional merging using BCFtools on large datasets, such as a 50k samples file derived from 50 files of 1k samples each, can be time-consuming. A direct merge might take **several days** for such datasets.

![Comparison Chart](comparison_chart.png)


By leveraging the parallel capabilities of this script, the merging process is expedited considerably. In test cases, the merging time was reduced to just **4 hours** for the aforementioned dataset, marking a substantial improvement.



## Features

- Extract unique positions from the VCF/BCF file and generates chunks of a defined size.
- Parallelizes the `bcftools merge` operation for improved performance on multi-core systems.
- Uses `bcftools concat` to assemble the chunks back into a single VCF/BCF file.
- Automatically indexes the final merged BCF file.

## Prerequisites

- [bcftools](https://github.com/samtools/bcftools) - my system has version 1.18
- [GNU Parallel](https://www.gnu.org/software/parallel/)

You can typically install these using package managers like `apt`, `brew`, or `conda`.

## How to run

To use the script:

```
./bcftools_merge_parallel.sh -l <file_list> -t <num_threads> -o <output_file>
```

### Options

- `-l`: Path to the list of VCF/BCF files to be merged. (e.g., `sample_to_merge.list` 1 file name per line )
- `-t`: Number of threads/cores to be used for parallel processing. (Default: 10)
- `-o`: Name of the final merged output BCF file. (Default: `merged_output.bcf.gz`)

### Example:

```
./bcftools_merge_parallel.sh -l sample_to_merge.list -t 10 -o test.bcf.gz
```

## Notes

- Ensure your input VCF/BCF files are correctly formatted and compliant with the VCF specification.
- It's recommended to have adequate disk space available, especially if working with large datasets, as intermediate files are generated during processing.

---
