#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

result_dir=/var/JunoTest
echo -e "Please Input the filename:\n"
read result_name_one
result_path_one=$result_dir/$result_name_one
read result_name_two
result_path_two=$result_dir/$result_name_two

if [ `ls $result_path_one | wc -l` -eq 0 ]
then
    echo "Input file "${result_path_one}" is not exist!!!"
    exit 1
fi

if [ `ls $result_path_two | wc -l` -eq 0 ]
then
    echo "Input file "${result_path_two}" is not exist!!!"
    exit 1
fi

junotest_result_string_one=$(cat ${result_path_one})
junotest_result_string_two=$(cat ${result_path_two})

junotest_score_one=$"( echo $junotest_result_string_one | jq '.junotest_result' )"
junotest_score_two=$"( echo $junotest_result_string_two | jq '.junotest_result' )"

if [ $junotest_score_one -ne 1 ]
then
    echo "Input file is uncorrect!!!"
    exit 1
fi      

if [ $junotest_score_two -ne 1 ]
then
    echo "Input file is uncorrect!!!"
    exit 1
fi      


juno_instance_length_one=$"( echo $junotest_result_string_one | jq '.instance_length' )"
juno_instance_length_two=$"( echo $junotest_result_string_two | jq '.instance_length' )"
instance_one=""
instance_two=""

for (( countone=0; countone<$juno_instance_length_one; ))
do
  countone++;
  eval juno_instance_Number_${countone}=\$"( echo \$junotest_result_string_one |  jq '.instance_Number_${countone}' )"
  j=$(eval echo \$juno_instance_Number_${countone})
  instance_one=${instance_one}" "${j}
  eval juno_DetSim_${j}_time_one=\$"( echo \$junotest_result_string_one |  jq '.DetSim_${j}_time' )"
  eval juno_Det2Elec_${j}_time_one=\$"( echo \$junotest_result_string_one |  jq '.Det2Elec_${j}_time' )"
  eval juno_Elec2Calib_${j}_time_one=\$"( echo \$junotest_result_string_one |  jq '.Elec2Calib_${j}_time' )"
  eval juno_Calib2Rec_${j}_time_one=\$"( echo \$junotest_result_string_one |  jq '.Calib2Rec_${j}_time' )"
done

for (( counttwo=0; counttwo<$juno_instance_length; ))
do
  counttwo++;
  eval juno_instance_Number_${counttwo}=\$"( echo \$juno_instance_length_two |  jq '.instance_Number_${counttwo}' )"
  j=$(eval echo \$juno_instance_Number_${counttwo})
  instance_two=${instance_two}" "${j}
  eval juno_DetSim_${j}_time_two=\$"( echo \$juno_instance_length_two |  jq '.DetSim_${j}_time' )"
  eval juno_Det2Elec_${j}_time_two=\$"( echo \$juno_instance_length_two |  jq '.Det2Elec_${j}_time' )"
  eval juno_Elec2Calib_${j}_time_two=\$"( echo \$juno_instance_length_two |  jq '.Elec2Calib_${j}_time' )"
  eval juno_Calib2Rec_${j}_time_two=\$"( echo \$juno_instance_length_two |  jq '.Calib2Rec_${j}_time' )"
done

echo -e "DetSim Test Result:\n\t instance \t"${result_name_one}"\t"${result_name_two}"\tDecline Percentage"
for j in $instance
do
   eval DetSim_DecPercent_${j}=\$(echo "scale=2; (\${juno_DetSim_${j}_time_one}-\${juno_DetSim_${j}_time_two})*100/\${juno_DetSim_${j}_time_one}" | bc -l)"%"
   echo -e "\t"${j}"\t"${eval juno_DetSim_${j}_time_one}"\t"${eval juno_DetSim_${j}_time_two}"\t"${eval DetSim_DecPercent_${j}}"\n"
done

echo -e "Elec Simulation Test Result:\n\t instance \t"${result_name_one}"\t"${result_name_two}"\tDecline Percentage"
for j in $instance
do
   eval Elec_DecPercent_${j}=\$(echo "scale=2; (\${juno_Det2Elec_${j}_time_one}-\${juno_Det2Elec_${j}_time_two})*100/\${juno_Det2Elec_${j}_time_one}" | bc -l)"%" 
   echo -e "\t"${j}"\t"${eval juno_Det2Elec_${j}_time_one}"\t"${eval juno_Det2Elec_${j}_time_two}"\t"${eval Elec_DecPercent_${j}}"\n"
done

echo -e "Calib Test Result:\n\t instance \t"${result_name_one}"\t"${result_name_two}"\tDecline Percentage"
for j in $instance
do
   eval Calib_DecPercent_${j}=\$(echo "scale=2; (\${juno_Elec2Calib_${j}_time_one}-\${juno_Elec2Calib_${j}_time_two})*100/\${juno_Elec2Calib_${j}_time_one}" | bc -l)"%"
   echo -e "\t"${j}"\t"${eval juno_Elec2Calib_${j}_time_one}"\t"${eval juno_Elec2Calib_${j}_time_two}"\t"${eval Calib_DecPercent_${j}}"\n"
done

echo -e "Reconstruction Test Result:\n\t instance \t"${result_name_one}"\t"${result_name_two}"\tDecline Percentage"
for j in $instance
do
   eval Rec_DecPercent_${j}=\$(echo "scale=2; (\${juno_Calib2Rec_${j}_time_one}-\${juno_Calib2Rec_${j}_time_two})*100/\${juno_Calib2Rec_${j}_time_one}" | bc -l)"%"
   echo -e "\t"${j}"\t"${eval juno_Calib2Rec_${j}_time_one}"\t"${eval juno_Calib2Rec_${j}_time_two}"\t"${eval Rec_DecPercent_${j}}"\n"
done

