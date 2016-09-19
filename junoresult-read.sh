#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

result_dir=/var/JunoTest
echo -e "Please Input the filename:\n"
read result_name
result_path=$result_dir/$result_name

if [ `ls $result_path | wc -l` -eq 0 ]
then
    echo "Input file "${result_path}" is not exist!!!"
    exit 1
fi

junotest_result_string=$(cat ${result_path})

junotest_score=$"( echo $junotest_result_string | jq '.junotest_result' )"
if [ $junotest_score -ne 1 ]
then
    echo "Input file is uncorrect!!!"
    exit 1
fi      

juno_instance_length=$"( echo $junotest_result_string | jq '.instance_length' )"
instance=""

for (( count=0; count<$juno_instance_length; ))
do
  count++;
  eval juno_instance_Number_${count}=\$"( echo \$junotest_result_string |  jq '.instance_Number_${count}' )"
  j=$(eval echo \$juno_instance_Number_${count})
  instance=${instance}" "${j}
  eval juno_DetSim_${j}_time=\$"( echo \$junotest_result_string |  jq '.DetSim_${j}_time' )"
  eval juno_Det2Elec_${j}_time=\$"( echo \$junotest_result_string |  jq '.Det2Elec_${j}_time' )"
  eval juno_Elec2Calib_${j}_time=\$"( echo \$junotest_result_string |  jq '.Elec2Calib_${j}_time' )"
  eval juno_Calib2Rec_${j}_time=\$"( echo \$junotest_result_string |  jq '.Calib2Rec_${j}_time' )"
done

echo -e "DetSim Test Result:\n\t instance \t time\n"
for j in $instance
do
   echo -e "\t"${j}"\t"${eval juno_DetSim_${j}_time}"\n"
done

echo -e "Elec Simulation Test Result:\n\t instance \t time\n"
for j in $instance
do
   echo -e "\t"${j}"\t"${eval juno_Det2Elec_${j}_time}"\n"
done

echo -e "Calib Test Result:\n\t instance \t time\n"
for j in $instance
do
   echo -e "\t"${j}"\t"${eval juno_Elec2Calib_${j}_time}"\n"
done

echo -e "Reconstruction Test Result:\n\t instance \t time\n"
for j in $instance
do
   echo -e "\t"${j}"\t"${eval juno_Calib2Rec_${j}_time}"\n"
done

