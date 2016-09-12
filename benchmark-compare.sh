#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

result_dir=/var/benchmark
echo -e "Now we will compare two results and see the decline percentage:\n"
echo -e "Please Input the first file name:\n"
read result_FileName_One
echo -e "Please Input the second file name:\n"
read result_FileName_Two
result_path_one=$result_dir/$result_FileName_One
result_path_two=$result_dir/$result_FileName_Two

if [ `ls $result_path_one  | wc -l` -eq 0 ]
then
    echo "Input file "${result_path_one}" is not exist!!!"
    exit 1
fi

if [ `ls $result_path_two  | wc -l` -eq 0 ]
then
    echo "Input file "${result_path_two}" is not exist!!!"
    exit 1
fi

benchmark_result_one=$(cat ${result_path_one})
benchmark_result_two=$(cat ${result_path_two})

unixbench_tag="Unixbench Score:"
One_unixbench_score=$"( echo $benchmark_result_one | jq "'."${unixbench_tag}"'" )"
Two_unixbench_score=$"( echo $benchmark_result_two | jq "'."${unixbench_tag}"'" )"
unixbench_DecPercent=$(echo "scale=2; ($One_unixbench_score-$Two_unixbench_score)*100/$One_unixbench_score" | bc -l)"%"


Stream_Copy_tag="Stream Copy:"
One_Stream_Copy_score=$"( echo $benchmark_result_one | jq "'."${Stream_Copy_tag}"'" )"
Two_Stream_Copy_score=$"( echo $benchmark_result_two | jq "'."${Stream_Copy_tag}"'" )"
Stream_Copy_DecPercent=$(echo "scale=2; ($One_Stream_Copy_score-$Two_Stream_Copy_score)*100/$One_Stream_Copy_score" | bc -l)"%"

Stream_Scale_tag="Stream SCale:"
One_Stream_Scale_score=$"( echo $benchmark_result_one | jq "'."${Stream_Scale_tag}"'" )"
Two_Stream_Scale_score=$"( echo $benchmark_result_two | jq "'."${Stream_Scale_tag}"'" )"
Stream_Scale_DecPercent=$(echo "scale=2; ($One_Stream_Scale_score-$Two_Stream_Scale_score)*100/$One_Stream_Scale_score" | bc -l)"%"

Stream_Add_tag="Stream Add:"
One_Stream_Add_score=$"( echo $benchmark_result_one | jq "'."${Stream_Add_tag}"'" )"
Two_Stream_Add_score=$"( echo $benchmark_result_two | jq "'."${Stream_Add_tag}"'" )"
Stream_Add_DecPercent=$(echo "scale=2; ($One_Stream_Add_score-$Two_Stream_Add_score)*100/$One_Stream_Add_score" | bc -l)"%"

Stream_Triad_tag="Stream Triad:"
One_Stream_Triad_score=$"( echo $benchmark_result_one | jq "'."${Stream_Triad_tag}"'" )"
Two_Stream_Triad_score=$"( echo $benchmark_result_two | jq "'."${Stream_Triad_tag}"'" )"
Stream_Triad_DecPercent=$(echo "scale=2; ($One_Stream_Triad_score-$Two_Stream_Triad_score)*100/$One_Stream_Triad_score" | bc -l)"%"

Iozone_Write_tag="Initial Write:"
One_Iozone_Write_score=$"( echo $benchmark_result_one | jq "'."${Iozone_Write_tag}"'" )"
Two_Iozone_Write_score=$"( echo $benchmark_result_two | jq "'."${Iozone_Write_tag}"'" )"
Iozone_Write_DecPercent=$(echo "scale=2; ($One_Iozone_Write_score-$Two_Iozone_Write_score)*100/$One_Iozone_Write_score" | bc -l)"%"

Iozone_ReWrite_tag="Rewrite:"
One_Iozone_ReWrite_score=$"( echo $benchmark_result_one | jq "'."${Iozone_ReWrite_score}"'" )"
Two_Iozone_ReWrite_score=$"( echo $benchmark_result_two | jq "'."${Iozone_ReWrite_score}"'" )"
Iozone_ReWrite_DecPercent=$(echo "scale=2; ($One_Iozone_ReWrite_score-$Two_Iozone_ReWrite_score)*100/$One_Iozone_ReWrite_score" | bc -l)"%"

Iozone_Read_tag="Read:"
One_Iozone_Read_score=$"( echo $benchmark_result_one | jq "'."${Iozone_Read_score}"'" )"
Two_Iozone_Read_score=$"( echo $benchmark_result_two | jq "'."${Iozone_Read_score}"'" )"
Iozone_Read_DecPercent=$(echo "scale=2; ($One_Iozone_Read_score-$Two_Iozone_Read_score)*100/$One_Iozone_Read_score" | bc -l)"%"

Iozone_ReRead_tag="ReRead:"
One_Iozone_ReRead_score=$"( echo $benchmark_result_one | jq "'."${Iozone_ReRead_score}"'" )"
Two_Iozone_ReRead_score=$"( echo $benchmark_result_two | jq "'."${Iozone_ReRead_score}"'" )"
Iozone_ReRead_DecPercent=$(echo "scale=2; ($One_Iozone_ReRead_score-$Two_Iozone_ReRead_score)*100/$One_Iozone_ReRead_score" | bc -l)"%"




echo -e "Cpu Test Result:\n\tTest Item:\t"${result_FileName_One}"\t"${result_FileName_Two}"\tDecline Percentage\n\t"${unixbench_tag}"\t"${One_unixbench_score}"\t"${Two_unixbench_score}"\t"${unixbench_DecPercent}"\n"

echo -e "Memory Test Result:\n\tTest Item:\t"${result_FileName_One}"\t"${result_FileName_Two}"\tDecline Percentage\n\t"${Stream_Copy_tag}"\t"${One_Stream_Copy_score}"\t"${Two_Stream_Copy_score}"\t"${Stream_Copy_DecPercent}"\n\t"${Stream_Scale_tag}"\t"${One_Stream_Scale_score}"\t"${Two_Stream_Scale_score}"\t"${Stream_Scale_DecPercent}"\n\t"${Stream_Add_tag}"\t"${One_Stream_Add_score}"\t"${Two_Stream_Add_score}"\t"${Stream_Add_DecPercent}"\n\t"${Stream_Triad_tag}"\t"${One_Stream_Triad_score}"\t"${Two_Stream_Triad_score}"\t"${Stream_Triad_DecPercent}"\n"

echo -e "IO Test Result:\n\tTest Item:\t"${result_FileName_One}"\t"${result_FileName_Two}"\tDecline Percentage\n\t"${Iozone_Write_tag}"\t"${One_Iozone_Write_score}"\t"${Two_Stream_Triad_score}"\t"${Iozone_Write_DecPercent}"\n\t"${Iozone_ReWrite_tag}"\t"${One_Iozone_ReWrite_score}"\t"${Two_Iozone_ReWrite_score}"\t"${Iozone_ReWrite_DecPercent}"\n\t"${Iozone_Read_tag}"\t"${One_Iozone_Read_score}"\t"${Two_Iozone_Read_score}"\t"${Iozone_Read_DecPercent}"\n\t"${Iozone_ReRead_tag}"\t"${One_Iozone_ReRead_score}""${Two_Iozone_ReRead_score}""${Iozone_ReRead_DecPercent}"\n"
