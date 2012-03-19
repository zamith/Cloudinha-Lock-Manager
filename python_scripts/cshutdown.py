#!/usr/bin/env python 
# -*- encoding: utf-8 -*- 

'''                                                                                                                 
Script to kill the machines by number or using the keyword all   
'''

import os,sys
from subprocess import call
import time

'''
Invocation 
'''

if len(sys.argv) == 1:
    print "-Error- : Insert machine number to shutdown or all keyword"
    os._exit(99)

arg_len = len(sys.argv)
for arg_i in xrange(1,arg_len):
    if sys.argv[arg_i].lower() == "all":
        for ip  in xrange (1,33):
            print "Sending ssh shutdown command to 192.168.111."+str(200+ip)+"..."
            call(["ssh","root@192.168.111."+str(200+ip),"shutdown -h now"])      
            time.sleep(1)
    elif '-' in sys.argv[arg_i]:
       mach_indexes = sys.argv[arg_i].split('-')
       if len(mach_indexes) != 2:
           print "-Error-: Invalid N-N range used"
           os._exit(99)
       for mach_index in xrange(int(mach_indexes[0]),int(mach_indexes[1])+1):
           if mach_index < 0:
               print "-Error- Only numbers in the range [1...N]"
           print "Sending ssh shutdown command to 192.168.111."+str(200+mach_index)+"..."
           call(["ssh","root@192.168.111."+str(200+mach_index),"shutdown -h now"])
           time.sleep(1)
    else:
        ip = int(sys.argv[arg_i])
        if ip < 0:
            print "-Error- Only numbers in the range [1...N]"
        print "Sending ssh shutdown command to 192.168.111."+str(200+ip)+"..."
        call(["ssh","root@192.168.111."+str(200+ip),"shutdown -h now"])
        time.sleep(1)
        
