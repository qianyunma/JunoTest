#!/bin/bash - 

set -o nounset                              # Treat unset variables as an error

function debug () {
    echo 1>&2 $*
}

function get-child() {                                                          
    debug $FUNCNAME
    local parent=$1                                                             
    local list=                                                                 
    local child=$(ps --ppid $parent -o pid h)                                   
    for c in $child;                                                            
    do                                                                          
        # check the child again                                                 
        if ps --pid $c -o pid h >& /dev/null; then                              
            echo $c                                                             
            get-child $c                                                        
        fi                                                                      
    done                                                                        
}                                                                               
                                                                                
function filter-child() {                                                       
    debug $FUNCNAME
    for c in $*                                                                 
    do                                                                          
        if [ -z "$c" ]; then
            continue
        fi
        if (ps --pid $c -o args h | grep python) >& /dev/null ;                  
        then                                                                    
            echo $c                                                             
        fi                                                                      
    done                                                                        
}                                                                               
                                                                                
function mom() {                                                                
    debug $FUNCNAME
    if [ "$#" -eq "0" ]; then
        debug please input a pid
        return
    fi
    local parent=$1                                                             
    if [ -z "$parent" ]; then
        debug please input a pid
        return
    fi
    sleep 1                                                                     
    echo parent: $parent                                                        
    local child=$(get-child $parent)                                            
    child=$(filter-child $child)                                                
    echo child: $child                                                          
    if [ -z "$child" ]; then 
        debug can not find any child 
        return 
    fi

    echo "IO Monitor Interval: $2"
    ps --pid $child -o args
    pidstat -dl -p $child

    while pidstat -dl -p $child | grep python  
    do 
        sleep $2
    done 
}                                                                               

while [ 1 -eq 1 ]
do 
    mom $* $2
done 

