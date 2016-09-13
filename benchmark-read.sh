#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

result_dir=/var/benchmark
echo -e "Please Input the filename:\n"
read result_name
result_path=$result_dir/$result_name

if [ `ls $result_path | wc -l` -eq 0 ]
then
    echo "Input file "${result_path}" is not exist!!!"
    exit 1
fi

benchmark_result_string=$(cat ${result_path})

benchmark_tag="becnchmark result"
benchmark_score=$"( echo $benchmark_result_string | jq "'."${benchmark_tag}"'" )"
if [ $benchmark_score -ne 1 ]
then
    echo "Input file is uncorrect!!!"
    exit 1
fi      

unixbench_tag="Unixbench Score"
unixbench_score=$"( echo $benchmark_result_string | jq "'."${unixbench_tag}"'" )"
Stream_Copy_tag="Stream Copy"
Stream_Copy_score=$"( echo $benchmark_result_string | jq "'."${Stream_Copy_tag}"'" )"
Stream_Scale_tag="Stream SCale"
Stream_Scale_score=$"( echo $benchmark_result_string | jq "'."${Stream_Scale_tag}"'" )"
Stream_Add_tag="Stream Add"
Stream_Add_score=$"( echo $benchmark_result_string | jq "'."${Stream_Add_tag}"'" )"
Stream_Triad_tag="Stream Triad"
Stream_Triad_score=$"( echo $benchmark_result_string | jq "'."${Stream_Triad_tag}"'" )"
Iozone_Write_tag="Initial Write"
Iozone_Write_score=$"( echo $benchmark_result_string | jq "'."${Iozone_Write_tag}"'" )"
Iozone_ReWrite_tag="Rewrite"
Iozone_ReWrite_score=$"( echo $benchmark_result_string | jq "'."${Iozone_ReWrite_score}"'" )"
Iozone_Read_tag="Read"
Iozone_Read_score=$"( echo $benchmark_result_string | jq "'."${Iozone_Read_score}"'" )"
Iozone_ReRead_tag="ReRead"
Iozone_ReRead_score=$"( echo $benchmark_result_string | jq "'."${Iozone_ReRead_score}"'" )"

echo -e "Cpu Test Result:\n\t"${unixbench_tag}"\t"${unixbench_score}"\n"
echo -e "Memory Test Result:\n\t"${Stream_Copy_tag}"\t"${Stream_Copy_score}"\n\t"${Stream_Scale_tag}"\t"${Stream_Scale_score}"\n\t"${Stream_Add_tag}"\t"${Stream_Add_score}"\n\t"${Stream_Triad_tag}"\t"${Stream_Triad_score}"\n"
echo -e "IO Test Speed Result:\n\t"${Iozone_Write_tag}"\t"${Iozone_Write_score}"\n\t"${Iozone_ReWrite_tag}"\t"${Iozone_ReWrite_score}"\n\t"${Iozone_Read_tag}"\t"${Iozone_Read_score}"\n\t"${Iozone_ReRead_tag}"\t"${Iozone_ReRead_score}"\n"
