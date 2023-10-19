---

# Parallel BCFtools Merge Script

This script provides a mechanism for parallelized merging of VCF/BCF files using `bcftools` and the `parallel` command. It chunks the VCF files based on unique positions and merges them in parallel before finally concatenating them.

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

- `-l`: Path to the list of VCF/BCF files to be merged. (e.g., `sample_to_merge`)
- `-t`: Number of threads/cores to be used for parallel processing. (Default: 10)
- `-o`: Name of the final merged output BCF file. (Default: `merged_output.bcf.gz`)

### Example:

```
./bcftools_merge_parallel.sh -l sample_to_merge -t 10 -o ciao.bcf.gz
```

## Notes

- Ensure your input VCF/BCF files are correctly formatted and compliant with the VCF specification.
- It's recommended to have adequate disk space available, especially if working with large datasets, as intermediate files are generated during processing.

---
