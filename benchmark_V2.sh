#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# configure Benchmarks 
CPU_BENCHMK_ON=1
MEM_BENCHMK_ON=1
IO_BENCHMK_ON=1

# configure important path
bhmk_home_dir=/opt
result_dir=/var/benchmark
log_dir=/var/log/benchmark
fifofile=output.fifo
mkdir -p $result_dir
mkdir -p $log_dir

# set & create log_file and result_file path
timestamp=`date +%Y_%m_%d-%H%M%S`
log_name=log.$timestamp 
log_path=$log_dir/$log_name
>$log_path

result_name=result.$timestamp 
result_path=$result_dir/$result_name
>$result_path

# set redirection of stdoutput and stderr
rm -f "$fifofile"
mkfifo $fifofile
cat $fifofile | tee -a $log_path &
exec 3>&1 #save stdoutput in fd=3
exec 4>&2
exec 1>$fifofile
exec 2>&1

# check authority and system 
[[ $EUID -ne 0 ]] && echo 'Error: This script must be run as root!' && exit 1
[[ -f /etc/redhat-release ]] && os='centos'
[[ ! -z "`egrep -i debian /etc/issue`" ]] && os='debian'
[[ ! -z "`egrep -i ubuntu /etc/issue`" ]] && os='ubuntu'
[[ "$os" == '' ]] && echo 'Error: Your system is not supported to run it!' && exit 1

# check benchmark exists

cd ${bhmk_home_dir}
# check Benchmark UnixBench
if [ `ls ${bhmk_home_dir}/UnixBench | wc -l` -eq 0 ]
then
    echo "Benchmark UnixBench not found!!!download now..."
    mkdir -p ${bhmk_home_dir}/UnixBench 

    # Install necessary libaries
    if [ "$os" == 'centos' ]
    then
        yum -y install make automake gcc autoconf gcc-c++ time perl-Time-HiRes
    else
        apt-get -y update
        apt-get -y install make automake gcc autoconf time perl
    fi

    # Download UnixBench5.1.3.tgz 
    if ! wget -c http://dl.teddysun.com/files/UnixBench5.1.3.tgz
    then
        echo "Failed to download UnixBench5.1.3.tgz, please download it to ${bhmk_home_dir} directory manually and try again."
        exit 1
    fi
    tar -zxvf UnixBench5.1.3.tgz && rm -f UnixBench5.1.3.tgz
else
    echo "Benchmark UnixBench found"
fi

# check Benchmark Stream
if [ `ls ${bhmk_home_dir}/Stream | wc -l` -eq 0 ]
then
    echo "Benchmark Stream not found!!!download now..."
    mkdir -p ${bhmk_home_dir}/Stream  

    # Install necessary libaries
    if [ "$os" == 'centos' ]
    then
        yum -y install make automake gcc gcc-c++ 
    else
        apt-get -y update
        apt-get -y install make automake gcc autoconf 
    fi
# Download Stream
    mkdir -p Stream  
    if ! wget -c http://www.cs.virginia.edu/stream/FTP/Code/stream.c -P Stream 
    then
        echo "Failed to download stream.c, please download it to ${bhmk_home_dir} directory manually and try again."
        exit 1
    fi
else
    echo "Bechmark Stream found"
fi

# check Benchmark IOzone
if [ `ls ${bhmk_home_dir}/IOzone | wc -l` -eq 0 ]
then
    echo "Benchmark IOzone not found!!!download now..."
    mkdir -p ${bhmk_home_dir}/IOzone   

    # Install necessary libaries
    if [ "$os" == 'centos' ]
    then
        yum -y install make automake gcc gcc-c++ 
    else
        apt-get -y update
        apt-get -y install make automake gcc autoconf 
    fi
# Download IOzone 
    if ! wget -c http://www.iozone.org/src/current/iozone3_465.tar 
    then
        echo "Failed to download IOzone, please download it to ${bhmk_home_dir} directory manually and try again."
        exit 1
    fi 
    tar -xvf iozone3_465.tar -C IOzone 
else
    echo "Bechmark IOzone found"

fi


# Run Benchmarks 
# /*****************************************Run UnixBench*************************************************/
if [ $CPU_BENCHMK_ON -eq 1 ]
then  
    cd ${bhmk_home_dir}/UnixBench 
    make 
    ./Run
fi 
# collect unixbench results
unixbench_str=$(grep "System Benchmarks Index Score" $log_path)
unixbench_tag="Unixbench Score"
unixbench_score_str=${unixbench_str##*e}
for element in $unixbench_score_str
do
unixbench_score=$element
done

# /*****************************************Run Stream*************************************************/
if [ $MEM_BENCHMK_ON -eq 1 ]
then 
    cd ${bhmk_home_dir}/Stream
    gcc -O -fopenmp -DSTREAM_ARRAY_SIZE=200000000 -DNTIME=20 stream.c -o stream.o
    ./stream.o
fi

# collect stream results

Stream_Copy_str=$(grep Function $log_path)
Stream_Copy_tag="Stream Copy"
Stream_Copy_score=0
count=0
for element in $Stream_Copy_str; do if [ $count = 2 ]; then  Stream_Copy_score=$element ; break; fi; count=$(($count+1)); done

Stream_Scale_str=$(grep Scale: $log_path)
Stream_Scale_tag="Stream SCale"
Stream_Scale_score=0
count=0
for element in $Stream_Scale_str; do if [ $count = 2 ]; then  Stream_Scale_score=$element ; break; fi; count=$(($count+1)); done

Stream_Add_str=$(grep Add: $log_path)
Stream_Add_tag="Stream Add"
Stream_Add_score=0
count=0
for element in $Stream_Add_str; do if [ $count = 2 ]; then  Stream_Add_score=$element ; break; fi; count=$(($count+1)); done

Stream_Triad_str=$(grep Triad: $log_path)
Stream_Triad_tag="Stream Triad"
Stream_Triad_score=0
count=0
for element in $Stream_Triad_str; do if [ $count = 2 ]; then  Stream_Triad_score=$element ; break; fi; count=$(($count+1)); done



 

# /*****************************************Run IOzone*************************************************/
Iozone_Write_tag="Initial Write"
Iozone_Write_str_2G=""
Iozone_Write_score_2G=0
Iozone_Write_str_4G=""
Iozone_Write_score_4G=0
Iozone_Write_str_6G=""
Iozone_Write_score_6G=0
Iozone_Write_str_8G=""
Iozone_Write_score_8G=0
Iozone_Write_str_10G=""
Iozone_Write_score_10G=0



Iozone_ReWrite_tag="Rewrite"
Iozone_ReWrite_str_2G=""
Iozone_ReWrite_score_2G=0
Iozone_ReWrite_str_4G=""
Iozone_ReWrite_score_4G=0
Iozone_ReWrite_str_6G=""
Iozone_ReWrite_score_6G=0
Iozone_ReWrite_str_8G=""
Iozone_ReWrite_score_8G=0
Iozone_ReWrite_str_10G=""
Iozone_ReWrite_score_10G=0



Iozone_Read_tag="Read"
Iozone_Read_str_2G=""
Iozone_Read_score_2G=0
Iozone_Read_str_4G=""
Iozone_Read_score_4G=0
Iozone_Read_str_6G=""
Iozone_Read_score_6G=0
Iozone_Read_str_8G=""
Iozone_Read_score_8G=0
Iozone_Read_str_10G=""
Iozone_Read_score_10G=0



Iozone_ReRead_tag="ReRead"
Iozone_ReRead_str_2G=""
Iozone_ReRead_score_2G=0
Iozone_ReRead_str_4G=""
Iozone_ReRead_score_4G=0
Iozone_ReRead_str_6G=""
Iozone_ReRead_score_6G=0
Iozone_ReRead_str_8G=""
Iozone_ReRead_score_8G=0
Iozone_ReRead_str_10G=""
Iozone_ReRead_score_10G=0




if [ $IO_BENCHMK_ON -eq 1 ]
then 
    cd ${bhmk_home_dir}/IOzone/iozone3_465/src/current/
    make && make linux
    echo 3 > /proc/sys/vm/drop_caches 
    #cores=`cat /proc/cpuinfo | grep "processor" | wc -l`
    #./iozone -i 0 -i 1 -t $[$cores / 2] -s 10G -r 1M -I -Rb $result_dir/$timestamp.xls
    for filesize in 2 4 6 8 10
    do
	 echo 3 > /proc/sys/vm/drop_caches 
         ./iozone -t 1 -s ${filesize}"G" -r 1M  -i 0 -i 1 -F TempFile.dat  -Rb $result_dir/${timestamp}"-"${filesize}"G".xls
         sleep 100s
         if [ $filesize = 2 ]; then  
               Iozone_Write_str_2G=$(grep "Initial write" $log_path);  Iozone_Write_score_2G=${Iozone_Write_str_2G##*"\""};
               Iozone_ReWrite_str_2G=$(grep "Rewrite" $log_path);      Iozone_ReWrite_score_2G=${Iozone_ReWrite_str_2G##*"\""};
               Iozone_Read_str_2G=$(grep "Read" $log_path);            Iozone_Read_score_2G=${Iozone_Read_str_2G##*"\""};
               Iozone_ReRead_str_2G=$(grep "Re-read" $log_path);       Iozone_ReRead_score_2G=${Iozone_ReRead_str_2G##*"\""};
         elif [ $filesize = 4 ]; then  
               Iozone_Write_str_4G=$(grep "Initial write" $log_path);  Iozone_Write_score_4G=${Iozone_Write_str_2G##*"\""};
               Iozone_ReWrite_str_4G=$(grep "Rewrite" $log_path);      Iozone_ReWrite_score_4G=${Iozone_ReWrite_str_2G##*"\""};
               Iozone_Read_str_4G=$(grep "Read" $log_path);            Iozone_Read_score_4G=${Iozone_Read_str_2G##*"\""};
               Iozone_ReRead_str_4G=$(grep "Re-read" $log_path);       Iozone_ReRead_score_4G=${Iozone_ReRead_str_2G##*"\""};
         elif [ $filesize = 6 ]; then  
               Iozone_Write_str_6G=$(grep "Initial write" $log_path);  Iozone_Write_score_6G=${Iozone_Write_str_2G##*"\""};
               Iozone_ReWrite_str_6G=$(grep "Rewrite" $log_path);      Iozone_ReWrite_score_6G=${Iozone_ReWrite_str_2G##*"\""};
               Iozone_Read_str_6G=$(grep "Read" $log_path);            Iozone_Read_score_6G=${Iozone_Read_str_2G##*"\""};
               Iozone_ReRead_str_6G=$(grep "Re-read" $log_path);       Iozone_ReRead_score_6G=${Iozone_ReRead_str_2G##*"\""};
         elif [ $filesize = 8 ]; then  
               Iozone_Write_str_8G=$(grep "Initial write" $log_path);  Iozone_Write_score_8G=${Iozone_Write_str_2G##*"\""};
               Iozone_ReWrite_str_8G=$(grep "Rewrite" $log_path);      Iozone_ReWrite_score_8G=${Iozone_ReWrite_str_2G##*"\""};
               Iozone_Read_str_8G=$(grep "Read" $log_path);            Iozone_Read_score_8G=${Iozone_Read_str_2G##*"\""};
               Iozone_ReRead_str_8G=$(grep "Re-read" $log_path);       Iozone_ReRead_score_8G=${Iozone_ReRead_str_2G##*"\""};
         elif [ $filesize = 10 ]; then  
               Iozone_Write_str_10G=$(grep "Initial write" $log_path);  Iozone_Write_score_10G=${Iozone_Write_str_2G##*"\""};
               Iozone_ReWrite_str_10G=$(grep "Rewrite" $log_path);      Iozone_ReWrite_score_10G=${Iozone_ReWrite_str_2G##*"\""};
               Iozone_Read_str_10G=$(grep "Read" $log_path);            Iozone_Read_score_10G=${Iozone_Read_str_2G##*"\""};
               Iozone_ReRead_str_10G=$(grep "Re-read" $log_path);       Iozone_ReRead_score_10G=${Iozone_ReRead_str_2G##*"\""};
         fi;               
 
         sleep 100s
    done
fi 

Iozone_Write_score=$(echo "scale=2; ($Iozone_Write_score_2G+$Iozone_Write_score_4G+$Iozone_Write_score_6G+$Iozone_Write_score_8G+$Iozone_Write_score_10G)/5" | bc -l)
Iozone_ReWrite_score=$(echo "scale=2; ($Iozone_ReWrite_score_2G+$Iozone_ReWrite_score_4G+$Iozone_ReWrite_score_6G+$Iozone_ReWrite_score_8G+$Iozone_ReWrite_score_10G)/5" | bc -l)
Iozone_Read_score=$(echo "scale=2; ($Iozone_Read_score_2G+$Iozone_Read_score_4G+$Iozone_Read_score_6G+$Iozone_Read_score_8G+$Iozone_Read_score_10G)/5" | bc -l)
Iozone_ReRead_score=$(echo "scale=2; ($Iozone_ReRead_score_2G+$Iozone_ReRead_score_4G+$Iozone_ReRead_score_6G+$Iozone_ReRead_score_8G+$Iozone_ReRead_score_10G)/5" | bc -l)

benchmark_tag="becnchmark result"
benchmark_score=1

echo "{ 
    \"$benchmark_tag\":\"$benchmark_score\" ,
    $unixbench_tag:\"$unixbench_score\" ,
    $Stream_Copy_tag:\"$Stream_Copy_score\" ,
    $Stream_Scale_tag:\"$Stream_Scale_score\" ,
    $Stream_Add_tag:\"$Stream_Add_score\" ,
    $Stream_Triad_tag:\"$Stream_Triad_score\" ,
    $Iozone_Write_tag:\"$Iozone_Write_score\" ,
    $Iozone_ReWrite_tag:\"$Iozone_ReWrite_score\" ,
    $Iozone_Read_tag:\"$Iozone_Read_score\" ,
    $Iozone_ReRead_tag:\"$Iozone_ReRead_score\",
    \"END\":\"END\"
}" > $result_path





#grep "System Benchmarks Index Score" $log_path > $result_path 
#grep Function $log_path >> $result_path
#grep Copy: $log_path >> $result_path
#grep Scale: $log_path >> $result_path
#grep Add: $log_path >> $result_path
#grep Triad: $log_path >> $result_path

# terminiate pipe and restore stdoutput and stderr
printf "\015"
exec 1>&3
exec 2>&4
rm -f "$fifofile"
