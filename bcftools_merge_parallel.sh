#!/bin/bash

# Function to get the first VCF file either from arguments or file set
function get_first_vcf() {
    cat ${1} | head -n 1
}

function ensure_vcf_indexed() {
    local vcf_list=$1
    local thread_count=$2
    while IFS= read -r vcf_file; do
        if [[ ! -f "${vcf_file}.csi" && ! -f "${vcf_file}.tbi" ]]; then
            echo "Index not found for ${vcf_file}. Indexing..."
            bcftools index ${vcf_file} --threads ${thread_count}
        fi
    done < "${vcf_list}"
}

# Extract unique positions from the VCF file and generate chunks of the given size.
function get_ranges() {
    local vcf_file=$1
    local chunk_size=500000
    local start=1
    local end=0
    local tmp_positions_file=$(mktemp ./chr_pos_tmp.XXXXXX)
    bcftools query -f '%CHROM\t%POS\n' ${vcf_file} > ${tmp_positions_file}
    local total_positions=$(wc -l < ${tmp_positions_file})
    while [ $start -le $total_positions ]; do
        end=$(($start + $chunk_size - 1))
        start_record=$(sed -n "${start}p" ${tmp_positions_file})
        start_chrom=$(echo "$start_record" | cut -f1)
        start_pos=$(echo "$start_record" | cut -f2)
        # If end position exceeds total_positions, set it to total_positions.
        if [ $end -gt $total_positions ]; then
            end=$total_positions
        fi
        end_record_next=$(sed -n "$(($end + 1))p" ${tmp_positions_file})
        end_pos_next=$(echo "$end_record_next" | cut -f2)
        # If end position isn't the last position in the file, subtract 1 from the next chunk's starting position.
        if [ $end -lt $total_positions ]; then
            end_pos=$(($end_pos_next - 1))
        else
            end_pos=$(echo "$end_record" | cut -f2)
        fi
        echo "${start_chrom}:${start_pos}-${end_pos}"
        start=$(($end + 1))
    done
    rm -f ${tmp_positions_file}
}

function parallel_bcftools_merge() {
    local find_vcf=$(get_first_vcf $FILE_LIST)
    echo "Calculate range on: $find_vcf"
    ensure_vcf_indexed ${FILE_LIST} ${PARALLEL_CORES}
    local ranges=$(get_ranges ${find_vcf})
    local current_dir=$(dirname ${find_vcf})
    local hash_merge=$(echo "$@" | md5sum | cut -c 1-5)
    local output_prefix="${current_dir}/parallel_merge.${hash_merge}"

    echo "current_dir: $current_dir"
    echo "output_prefix: $output_prefix"
    echo "threads: $PARALLEL_CORES"

    parallel --gnu --workdir ${current_dir} --env args -j ${PARALLEL_CORES} \
    "bcftools merge -r {1} --regions-overlap 0 -Ob --threads 2 -l ${FILE_LIST} -o" ${output_prefix}".{1}.bcf.gz" ::: ${ranges}
    
    local order=$(echo $ranges | tr ' ' '\n' | awk -v "prefix=${output_prefix}" '{ print prefix "." $0 ".bcf.gz" }' | sort -V )
    bcftools concat ${order} -n -o ${FINAL_FILE_MERGED} --threads ${PARALLEL_CORES}
    echo "writing index..."
    bcftools index ${FINAL_FILE_MERGED} --threads ${PARALLEL_CORES}
    rm ${order}
    echo "output created -->> ${FINAL_FILE_MERGED}"
}

# Defaults
PARALLEL_CORES=10
FINAL_FILE_MERGED="merged_output.bcf.gz"
FILE_LIST=""

while getopts ":l:t:o:" option; do
    case "${option}" in
        l)
            FILE_LIST=${OPTARG}
            ;;
        t)
            PARALLEL_CORES=${OPTARG}
            ;;
        o)
            FINAL_FILE_MERGED=${OPTARG}
            ;;
    esac
done
#./bcftools_merge_parallel.sh -l sample_to_merge -t 10 -o ciao.bcf.gz

shift $((OPTIND-1))
parallel_bcftools_merge "$@"
