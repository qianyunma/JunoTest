#!/bin/bash

set -o errexit
set -o pipefail
#set -o nounset

# Set Juno scripts path
JunoScript=/JUNOTest

# Check if cvmfs mounted


# Set Env vars & Copy Juno scripts from read-only /cvmfs dir to executable
source /cvmfs/juno.ihep.ac.cn/sl6_amd64_gcc44/J16v2r1-Pre2/setup.sh 
#cp -r /cvmfs/juno.ihep.ac.cn/sl6_amd64_gcc44/J16v2r1-Pre2/offline/ $JunoScript 
cd $JunoScript/offline/Examples/Tutorial/share/ 

# configure important path
result_dir=/var/JunoTest
log_dir=/var/log/JunoTest 
fifofile=output.fifo
mkdir -p $result_dir
mkdir -p $log_dir
mkdir -p $log_dir/IO_Monitor 
mkdir -p $log_dir/MEM_Monitor 

# set & create log_file and result_file mem_monitor io_monitor path
timestamp=`date +%Y_%m_%d-%H%M%S`
log_name=log.$timestamp 
log_path=$log_dir/$log_name
>$log_path

result_name=result.$timestamp 
result_path=$result_dir/$result_name
>$result_path

sim=sim.$timestamp 
result_sim=$result_dir/$sim 
>$result_sim 

elec=elec.$timestamp 
result_elec=$result_dir/$elec 
>$result_elec

calib=calib.$timestamp 
result_calib=$result_dir/$calib 
>$result_calib

rec=rec.$timestamp 
result_rec=$result_dir/$rec 
>$result_rec

IO_Monitor_name=IO.$timestamp
IO_Monitor_path=$log_dir/IO_Monitor/$IO_Monitor_name 
>$IO_Monitor_path 

MEM_Monitor_name=MEM.$timestamp
MEM_Monitor_path=$log_dir/MEM_Monitor/$MEM_Monitor_name 
>$MEM_Monitor_path 

# set instance num and round
instance="2 4 6 8 10 12"      # set array
round=1

# Monitor Settings
MEM_ON=1        # if set mem monitor
IO_ON=1         # if set IO monitor 
MEM_Interval=5  # set Mem monitor interval
IO_Interval=5   # set IO monitor interval(s)

# set redirection of stdoutput and stderr
rm -f "$fifofile"
mkfifo $fifofile
cat $fifofile | tee -a $log_path &
exec 3>&1 #save stdoutput in fd=3
exec 4>&2
exec 1>$fifofile
exec 2>&1

if [ $MEM_ON -eq 1 ]
then  
    ./MemMon.sh $$ $MEM_Interval > $MEM_Monitor_path &  
    mem_monitor_pid=`pgrep -f MemMon.sh`
fi

if [ $IO_ON -eq 1 ]
then  
    ./IOMon.sh $$ $IO_Interval > $IO_Monitor_path &  
    io_monitor_pid=`pgrep -f IOMon.sh`
fi


instance_length=0
# record job run time
for j in $instance
do
    for (( i=0; i<$round; i++ ))
    do 
        echo 3 > /proc/sys/vm/drop_caches 
        time -p (python tut_detsim.py --evtmax $j gun > $result_sim )
        eval ''Detsim_${j}_round${i}'=$(grep "real" $log_path | tail -1)'

        echo 3 > /proc/sys/vm/drop_caches
        sleep 60s
        time -p (python tut_det2elec.py --evtmax $j > $result_elec )
        eval ''Det2Elec_${j}_round${i}'=$(grep "real" $log_path | tail -1)'

        echo 3 > /proc/sys/vm/drop_caches
        sleep 60s
        time -p (python tut_elec2calib.py --evtmax $j > $result_calib )
        eval ''Elec2Calib_${j}_round${i}'=$(grep "real" $log_path | tail -1)'

        echo 3 > /proc/sys/vm/drop_caches
        sleep 60s
        time -p (python tut_calib2rec.py --evtmax $j > $result_rec )
        eval ''Calib2Rec_${j}_round${i}'=$(grep "real" $log_path | tail -1)'

        rm -f *.root
        echo 3 > /proc/sys/vm/drop_caches
        sleep 60s
    done
    instance_length=$[$instance_length+1]
done

#calculate job average time
for j in $instance
do
    eval ''DetSim_${j}_time'=0'
    eval ''Det2Elec_${j}_time'=0'
    eval ''Elec2Calib_${j}_time'=0'
    eval ''Calib2Rec_${j}_time'=0'
    
    for (( i=0; i<$round; i++ ))
    do 
        eval ''DetSim_${j}_time'=$(echo "scale=2;($'DetSim_${j}_time'+$'DetSim_${j}_round${i}')" |bc -l )'
        eval ''Det2Elec_${j}_time'=$(echo "scale=2;($'Det2Elec_${j}_time'+$'Det2Elec_${j}_round${i}')" |bc -l )'
        eval ''Elec2Calib_${j}_time'=$(echo "scale=2;($'Elec2Calib_${j}_time'+$'Elec2Calib_${j}_round${i}')" |bc -l )'
        eval ''Calib2Rec_${j}_time'=$(echo "scale=2;($'Calib2Rec_${j}_time'+$'Calib2Rec_${j}_round${i}')" |bc -l )'
    done
    
    eval ''DetSim_${j}_time'=$(echo "scale=2;($'DetSim_${j}_time'/$round)" |bc -l )'
    eval ''Det2Elec_${j}_time'=$(echo "scale=2;($'Det2Elec_${j}_time'/$round)" |bc -l )'
    eval ''Elec2Calib_${j}_time'=$(echo "scale=2;($'Elec2Calib_${j}_time'/$round)" |bc -l )'
    eval ''Calib2Rec_${j}_time'=$(echo "scale=2;($'Calib2Rec_${j}_time'/$round)" |bc -l )'

done



echo 
"{ \"junotest_result\":\"1\" ,
   \"instance_length\":"\""$instance_length"\"" ,
"  > $result_path

count=0
for j in $instance
do
  count++;
  eval echo '\"instance_Number_${count}\":\"$j\" ,
            \"DetSim_${j}_time\":\"$'DetSim_${j}_time'\" ,
            \"DetSim_${j}_time\":\"$'DetSim_${j}_time'\" ,
            \"Det2Elec_${j}_time\":\"$'Det2Elec_${j}_time'\" ,
            \"Elec2Calib_${j}_time\":\"$'Elec2Calib_${j}_time'\" ,
            \"Calib2Rec_${j}_time\":\"$'Calib2Rec_${j}_time'\" ,
            ' >> $result_path
done

echo    
"\"end\":\"end\"
}" >> $result_path




if [ $MEM_ON -eq 1 ]
then 
    kill -9 $mem_monitor_pid    # Or directly use pkill
fi 

if [ $IO_ON -eq 1 ]
then 
    kill -9 $io_monitor_pid    # Or directly use pkill
fi 

# terminiate pipe and restore stdoutput and stderr
printf "\015"
exec 1>&3
exec 2>&4
rm -f "$fifofile"
