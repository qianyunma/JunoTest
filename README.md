# JunoTest

## benchmk.sh
basic benchmark test:   
* CPU: UnixBench
* MEM: Stream
* IO: IOzone

**Configure**: In this script, you can configure whether test CPU/Mem/IO benchmark. Also you can configure your test log and result directory.   
**Description**: First, this script would check your system and authority, this script should be run in root authority. Next, this script would check every benchmark whether exists, if not we will install and configure it. At last, this script will run the choosed benchmarks.

## MemMon.sh
**Description**: This script mainly the mem usage of our intrested process (juno processes)

## IOMon.sh
**Description**: This script mainly the IO usage of our intrested process (juno processes)

## junotest.sh
You can test juno sim, elec, calib, rec processes' running time, mem usage, I/O usage.

**Configure**: In this script, you can configure whether monitor Mem/IO information, besides you can configure Mem/IO monitor interval. Also you can configure your test log and mem/IO mointor information and each process's running time directory.   



