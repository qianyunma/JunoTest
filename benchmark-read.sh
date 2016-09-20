#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

result_dir=/var/benchmark
echo -e "Please Input the filename:"
read result_name
result_path=$result_dir/$result_name

if [ `ls $result_path | wc -l` -eq 0 ]
then
    echo "Input file "${result_path}" is not exist!!!"
    exit 1
fi

benchmark_result_string=$(cat ${result_path})

yum -y install jq >/dev/null 2&>1

benchmark_tag="benchmarkresult"
benchmark_score=` echo $benchmark_result_string | jq '.'${benchmark_tag}'' `
tmpconstant="\"1\""
if [ $benchmark_score != $tmpconstant ]
then
    echo "Input file is uncorrect!!!"
    exit 1
fi      

unixbench_tag="UnixbenchScore"
unixbench_score=` echo $benchmark_result_string | jq '.'${unixbench_tag}'' `
Stream_Copy_tag="StreamCopy"
Stream_Copy_score=` echo $benchmark_result_string | jq '.'${Stream_Copy_tag}'' `
Stream_Scale_tag="StreamSCale"
Stream_Scale_score=` echo $benchmark_result_string | jq '.'${Stream_Scale_tag}'' `
Stream_Add_tag="StreamAdd"
Stream_Add_score=` echo $benchmark_result_string | jq '.'${Stream_Add_tag}'' `
Stream_Triad_tag="StreamTriad"
Stream_Triad_score=` echo $benchmark_result_string | jq '.'${Stream_Triad_tag}'' `
Iozone_Write_tag="InitialWrite"
Iozone_Write_score=` echo $benchmark_result_string | jq '.'${Iozone_Write_tag}'' `
Iozone_ReWrite_tag="Rewrite"
Iozone_ReWrite_score=` echo $benchmark_result_string | jq '.'${Iozone_ReWrite_tag}'' `
Iozone_Read_tag="Read"
Iozone_Read_score=` echo $benchmark_result_string | jq '.'${Iozone_Read_tag}'' `
Iozone_ReRead_tag="ReRead"
Iozone_ReRead_score=` echo $benchmark_result_string | jq '.'${Iozone_ReRead_tag}'' `

echo -e "Cpu Test Result:\n\t"${unixbench_tag}"\t"${unixbench_score}"\n"
echo -e "Memory Test Result(s):\n\t"${Stream_Copy_tag}"\t"${Stream_Copy_score}"\n\t"${Stream_Scale_tag}"\t"${Stream_Scale_score}"\n\t"${Stream_Add_tag}"\t"${Stream_Add_score}"\n\t"${Stream_Triad_tag}"\t"${Stream_Triad_score}"\n"
echo -e "IO Test Speed Result(MB/S):\n\t"${Iozone_Write_tag}"\t"${Iozone_Write_score}"\n\t"${Iozone_ReWrite_tag}"\t\t"${Iozone_ReWrite_score}"\n\t"${Iozone_Read_tag}"\t\t"${Iozone_Read_score}"\n\t"${Iozone_ReRead_tag}"\t\t"${Iozone_ReRead_score}"\n"
