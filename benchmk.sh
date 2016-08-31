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
# Run UnixBench 
if [ $CPU_BENCHMK_ON -eq 1 ]
then  
    cd ${bhmk_home_dir}/UnixBench 
    make 
    ./Run
fi 

# Run Stream
if [ $MEM_BENCHMK_ON -eq 1 ]
then 
    cd ${bhmk_home_dir}/Stream
    gcc -O -fopenmp -DSTREAM_ARRAY_SIZE=100000000 -DNTIME=20 stream.c -o stream.o
    ./stream.o
fi 

# Run IOzone
if [ $IO_BENCHMK_ON -eq 1 ]
then 
    cd ${bhmk_home_dir}/IOzone/iozone3_465/src/current/
    make && make linux
    echo 3 > /proc/sys/vm/drop_caches 
    cores=`cat /proc/cpuinfo | grep "processor" | wc -l`
    ./iozone -i 0 -i 1 -t $[$cores / 2] -s 10G -r 1M -I -Rb $result_dir/$timestamp.xls
fi 

# collect results
grep "System Benchmarks Index Score" $log_path > $result_path 
grep Function $log_path >> $result_path
grep Copy: $log_path >> $result_path
grep Scale: $log_path >> $result_path
grep Add: $log_path >> $result_path
grep Triad: $log_path >> $result_path

# terminiate pipe and restore stdoutput and stderr
printf "\015"
exec 1>&3
exec 2>&4
rm -f "$fifofile"

