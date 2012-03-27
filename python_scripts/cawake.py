#!/usr/bin/env python
# -*- encoding: utf-8 -*-

'''
Script to awake the machines by number or using the keyword all
'''   
import os,sys
from subprocess import call
import time

'''
Invocation 
'''  
mac_addresses = []

mac_addresses.append("d0:67:e5:0c:2f:7f")
mac_addresses.append("d0:67:e5:0c:8d:ab")
mac_addresses.append("d0:67:e5:0c:8a:16")
mac_addresses.append("d0:67:e5:0c:a2:90")
mac_addresses.append("d0:67:e5:0c:a1:dc")
mac_addresses.append("d0:67:e5:0c:8d:28")
mac_addresses.append("d0:67:e5:0c:89:a8")
mac_addresses.append("d0:67:e5:0c:89:01")
mac_addresses.append("d0:67:e5:0c:30:66")
mac_addresses.append("d0:67:e5:0c:8d:88")
mac_addresses.append("d0:67:e5:0c:93:56")
mac_addresses.append("d0:67:e5:0c:88:f3")
mac_addresses.append("d0:67:e5:0c:85:64")
mac_addresses.append("d0:67:e5:0c:8d:22")
mac_addresses.append("d0:67:e5:0c:87:5e")
mac_addresses.append("d0:67:e5:0c:30:6b")
mac_addresses.append("d0:67:e5:0c:89:b3")
mac_addresses.append("d0:67:e5:0c:8c:f9")
mac_addresses.append("d0:67:e5:0c:8d:29")
mac_addresses.append("d0:67:e5:0c:35:b5")
mac_addresses.append("d0:67:e5:0c:87:d5")
mac_addresses.append("d0:67:e5:0c:8a:28")
mac_addresses.append("d0:67:e5:0c:30:68")
mac_addresses.append("d0:67:e5:0c:93:48")
mac_addresses.append("d0:67:e5:0c:89:7c")
mac_addresses.append("d0:67:e5:0c:8d:66")
mac_addresses.append("d0:67:e5:0c:84:21")
mac_addresses.append("d0:67:e5:0c:84:31")
mac_addresses.append("d0:67:e5:0c:8c:23")
mac_addresses.append("d0:67:e5:0c:8c:25")
mac_addresses.append("d0:67:e5:0c:4c:50")
mac_addresses.append("d0:67:e5:0c:32:0c")
mac_addresses.append("d0:67:e5:0c:8d:7a")
mac_addresses.append("d0:67:e5:0c:30:67")
mac_addresses.append("d0:67:e5:0c:8f:0b")
mac_addresses.append("d0:67:e5:0c:a2:bf")

#macs_file = open("macs.txt", 'rb')
#for line in macs_file:
#    mac_addresses.append(line)



if len(sys.argv) == 1:
    print "-Error- : Insert machine number to power on or use the all keyword"
    os._exit(99)

sleep_time = 30
start = 1

if sys.argv[1].lower() == "-t":
    sleep_time  = int(sys.argv[2])
    start = 3

arg_len = len(sys.argv)
mach_it=0
for arg_i in xrange(start,arg_len):
    if sys.argv[arg_i].lower() == "all":

        for mac in mac_addresses:
            mach_it+=1
            sys.stdout.write(str(mach_it)+"| waking the machine "+str(mac_it)+" \n")
            call(["wakeonlan","-i","192.168.111.255",mac])
            if mac != mac_addresses[-1]:
                print ">Sleeping "+ str(sleep_time)  +" seconds to avoid power problems..."
                time.sleep(sleep_time)	
    elif '-' in sys.argv[arg_i]:
       mac_indexes = sys.argv[arg_i].split('-')
       if len(mac_indexes) != 2:
           print "-Error-: Invalid N-N range used"
           os._exit(99)
       for mac_index in xrange(int(mac_indexes[0]),int(mac_indexes[1])+1):
           if mac_index < 0:
               print "-Error- Only numbers in the range [1...N]"
           mach_it+=1
           sys.stdout.write(str(mach_it)+"| waking the machine "+str(mac_index)+" \n")
           call(["wakeonlan","-i","192.168.111.255",mac_addresses[mac_index-1]])
           if mac_index != int(mac_indexes[1]):
               print ">Sleeping "+ str(sleep_time) +" seconds to avoid power problems..."
               time.sleep(sleep_time)
           elif arg_i != (arg_len-1):
               print ">Sleeping "+ str(sleep_time) +" seconds to avoid power problems..."
               time.sleep(sleep_time)
    else:
        mac_index = int(sys.argv[arg_i])-1
        if mac_index < 0:
            print "-Error- Only numbers in the range [1...N]"
        mach_it+=1
        sys.stdout.write(str(mach_it)+"| waking the machine "+str(mac_index+1)+" \n")
        call(["wakeonlan","-i","192.168.111.255",mac_addresses[mac_index]])
        if arg_i != (arg_len-1):
            print ">Sleeping "+ str(sleep_time) +" seconds to avoid power problems..."
            time.sleep(sleep_time)
