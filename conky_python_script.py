import re
import psutil 
from shutil import copyfile
import os
import math
import subprocess
from gpuinfo import GPUInfo
import time
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Section 1: Update sensor gauges 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

temps=psutil.sensors_temperatures()

temp=temps['k10temp'][0][1]

temp_int=int(round(temp*1.1/2))*2
if temp_int<30:
	temp_int=0 
#Yellow at 50; light orange at 70; deep orange at 76; red at 84

dest='/home/storms/Progress/Images/gauges/temp_gaugej_bl.png'

temp_str=str(temp_int)
src='/home/storms/Progress/Images/gauges/bottom_left/temp_gaugej_bl_'+temp_str+'.png'

copyfile(src,dest)

cpu=psutil.cpu_percent(interval=0.2, percpu=False)

if cpu>0:
	cpu_str=str(math.ceil(cpu))

	dest='/home/storms/Progress/Images/gauges/temp_gaugej_tl.png'
	src='/home/storms/Progress/Images/gauges/top_left/temp_gaugej_tl_'+cpu_str+'.png'
	copyfile(src,dest)



mem_stat=psutil.virtual_memory()
mem=mem_stat[3]/10**9 
mem_str=str(int(round(mem/2)*2))

dest='/home/storms/Progress/Images/gauges/temp_gaugej_br.png'


src='/home/storms/Progress/Images/gauges/bottom_right/temp_gaugej_br_'+mem_str+'.png'

copyfile(src,dest)


gpu_temp=int(subprocess.check_output(["nvidia-settings -query [gpu:0]/GPUCoreTemp -t"],shell=True).decode("utf-8"))
gpu_temp=str(14+2*round(gpu_temp/2))
src='/home/storms/Progress/Images/gauges/top_right/temp_gaugej_tr_'+gpu_temp+'.png'
dest='/home/storms/Progress/Images/gauges/temp_gaugej_tr.png'

copyfile(src,dest)

use_stats=GPUInfo.gpu_usage()
gpu_usage=use_stats[0][0]
vram_usage=round(use_stats[1][0]/1000)

dest='/home/storms/Progress/Images/gauges/zotac_symbol.png'
src='/home/storms/Progress/Images/gauges/zotac_body/zotac_gaming_logo' + str(gpu_usage)+'-01.png'
copyfile(src,dest)





dest='/home/storms/Progress/Images/gauges/Zotac_Wings.png'
src='/home/storms/Progress/Images/gauges/Zotac_Wings/zotac_wings' + str(vram_usage)+'.png'
copyfile(src,dest)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Section 2: Update Progress Bars 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

f= open('/home/storms/Progress/main_prog.txt','r')
prog=int(f.read())
f.close()



f= open('/home/storms/Progress/main_todo.txt','r')
todo=int(f.read())
f.close()

if todo>0:
	main_perc=str(round(100*prog/todo))

	src='/home/storms/Progress/Images/progress_bars/main_left/progress_gauage_l_'+main_perc+'-01.png'
	dest='/home/storms/Progress/Images/progress_bars/progress_gauage_l.png'

	copyfile(src,dest)



f= open('/home/storms/Progress/OA_prog.txt','r')
prog=int(f.read())
f.close()

f= open('/home/storms/Progress/OA_todo.txt','r')
todo=int(f.read())
f.close()

if todo>0:
	OA_perc=str(round(100*prog/todo))

	src='/home/storms/Progress/Images/progress_bars/main_right/progress_gauage_r_'+OA_perc+'-01.png'
	dest='/home/storms/Progress/Images/progress_bars/progress_gauage_r.png'

	copyfile(src,dest)





f= open('/home/storms/Progress/mini_prog.txt','r')
prog=int(f.read())
f.close()


f= open('/home/storms/Progress/mini_todo.txt','r')
todo=int(f.read())
f.close()

if todo>0:
	mini_perc=str(round(100*prog/todo))

	src='/home/storms/Progress/Images/progress_bars/mini/progress_gauage_m_'+mini_perc+'.png'
	dest='/home/storms/Progress/Images/progress_bars/progress_gauage_m.png'

	copyfile(src,dest)





f= open('/home/storms/Progress/mega_prog.txt','r')
prog=int(f.read())
f.close()


f= open('/home/storms/Progress/mega_todo.txt','r')
todo=int(f.read())
f.close()

if todo>0:
	mega_perc=str(round(100*prog/todo))

	src='/home/storms/Progress/Images/progress_bars/mini2/progress_gauage_m2_'+mega_perc+'.png'
	dest='/home/storms/Progress/Images/progress_bars/progress_gauage_m2.png'




	copyfile(src,dest)




f= open('/home/storms/Progress/oa_sup_prog.txt','r')
prog=int(f.read())
f.close()


f= open('/home/storms/Progress/oa_sup_todo.txt','r')
todo=int(f.read())
f.close()


if todo>0:
	oa_sup_perc=str(round(100*prog/todo))
	src='/home/storms/Progress/Images/gauges/line_bar_mega_suptask/line_bar_right'+oa_sup_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_suptask.png'



	copyfile(src,dest)

else:

	oa_sup_perc=str(0)
	src='/home/storms/Progress/Images/gauges/line_bar_mega_suptask/line_bar_right'+oa_sup_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_suptask.png'

	copyfile(src,dest)










f= open('/home/storms/Progress/oa_sub_prog.txt','r')
prog=int(f.read())
f.close()


f= open('/home/storms/Progress/oa_sub_todo.txt','r')
todo=int(f.read())
f.close()


if todo>0:
	oa_sub_perc=str(round(100*prog/todo))
	src='/home/storms/Progress/Images/gauges/line_bar_mini/line_bar_right'+oa_sub_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_mini.png'



	copyfile(src,dest)

else:

	oa_sub_perc=str(0)
	src='/home/storms/Progress/Images/gauges/line_bar_mini/line_bar_right'+oa_sub_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_mini.png'

	copyfile(src,dest)






f= open('/home/storms/Progress/mega_sub_prog.txt','r')
prog=int(f.read())
f.close()


f= open('/home/storms/Progress/mega_sub_todo.txt','r')
todo=int(f.read())
f.close()

if todo>0:

	mega_sub_perc=str(round(100*prog/todo))
	src='/home/storms/Progress/Images/gauges/line_bar_mega_subtask/line_bar_right'+mega_sub_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_mega_subtask.png'

	copyfile(src,dest)

else:
	mega_sub_perc=str(0)
	src='/home/storms/Progress/Images/gauges/line_bar_mega_subtask/line_bar_right'+mega_sub_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_mega_subtask.png'

	copyfile(src,dest)








f= open('/home/storms/Progress/SUBOA_prog.txt','r')
prog=int(f.read())
f.close()


f= open('/home/storms/Progress/SUBOA_todo.txt','r')
todo=int(f.read())
f.close()

if todo>0:

	suboa_perc=str(round(100*prog/todo))
	src='/home/storms/Progress/Images/gauges/line_bar_suboa/line_bar_right'+suboa_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_suboa.png'

	copyfile(src,dest)

else:
	suboa_perc=str(0)
	src='/home/storms/Progress/Images/gauges/line_bar_suboa/line_bar_right'+suboa_perc+'-01.png'
	dest='/home/storms/Progress/Images/gauges/line_bar_suboa.png'

	copyfile(src,dest)




