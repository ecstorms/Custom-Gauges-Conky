--[[File Start--]]


corner_r=35
bg_colour=color8
bg_alpha=0.2



color9="0xea0b7a"
color44="0x0774f2"
color0="0x34cdff"
color1="0x3A3A3C"
color8="0x000000"
color7="0xb20016"
color6="0xcc2a13"
color5="0xde4710"
color4="0xff8d09"
color3="0xf4b642"

color2="0xfaff00"




require 'cairo'

function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

sensors = {
  values=nil,
  cmd="sensors |grep 'Tdie:.*' | cut -c 16-19",
  ts_read_i=10, ts_read=0,
}



sensors_avg = {
  values=nil,
  cmd='cat /home/storms/Progress/avg_core_temp.txt',
  ts_read_i=10, ts_read=0,
}


mem_vals= {
  values=nil,
  cmd='cat /proc/meminfo | grep "MemTotal" | cut -c 10-25',
  cmd2='cat /proc/meminfo | grep "MemFree" | cut -c 10-25',
  ts_read_i=10, ts_read=0,
}


function conky_get_memtotal()
  local ts = os.time()
  if os.difftime(ts, mem_vals.ts_read) > mem_vals.ts_read_i then
    local sh = io.popen(mem_vals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 20
    else
        local output = sh:read('*number')
        sh:close()
        return math.floor(output/1000000)
    end 
  end
  return ''
end


function conky_get_memfree()
  local ts = os.time()
  if os.difftime(ts, mem_vals.ts_read) > mem_vals.ts_read_i then
    local sh = io.popen(mem_vals.cmd2, 'r')
    if sh==nil then 
        sh:close()
        return 20
    else
        local output = sh:read('*number')
        sh:close()
        free=conky_round(output/1000)
        in_use=conky_get_memtotal()-free
        return in_use
    end 
  end
  return ''
end


 function conky_round(arg)
  local n = conky_parse(arg)
  return math.floor((tonumber(n)/1000)+.5)
 end


function conky_sens_read()
  local ts = os.time()
  if os.difftime(ts, sensors.ts_read) > sensors.ts_read_i then
    local sh = io.popen(sensors.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 20
    else
        local output = sh:read('*number')
        sh:close()
        return output
    end 
  end

  return ''
end



function conky_avg_sens_read()
  local ts = os.time()
  if os.difftime(ts, sensors_avg.ts_read) > sensors_avg.ts_read_i then
    local sh = io.popen(sensors_avg.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 20
    else
        local output = sh:read('*number')
        sh:close()
        return output
    end 
  end

  return ''
end

function conky_sum(a,b)
  return a+b
end

local file = io.popen("grep -c processor /proc/cpuinfo")
local numcpus = file:read("*n")
file:close()
listcpus = ""
for i = 1,numcpus
do  listcpus = listcpus.."${cpu cpu"..tostring(i).."} "
end

function conky_mycpus()
 return listcpus
end

function conky_average(...)
  local sum = 0
  local count = 0

  for _, v in ipairs({...}) do
     sum = sum + conky_parse(v)
     count = count + 1
  end

  return (sum / count)
end


function conky_count_active()
  local count = 0
  for i=1,64 do
    strng='${cpu cpu'..tostring(i)..'}'
    if tonumber(conky_parse(strng))>20 then
      count=count+1
    end 
  end
  return count 
end


--[[----------Functions for reading in details for progress text --------------------------------------------------------------]]




fileVals = {
  values=nil,
  cmdstart="cat /home/storms/Progress/proc",
  cmdend="_progress.txt | grep '[0-9']",
  ts_read_i=10, ts_read=0,
}


function conky_prog_read(proc_num)
  local ts = os.time()

  if os.difftime(ts, fileVals.ts_read) > fileVals.ts_read_i then
    local sh = io.popen(fileVals.cmdstart..proc_num..fileVals.cmdend, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end


todoVals = {
  values=nil,
  cmdstart="cat /home/storms/Progress/proc",
  cmdend="_todo.txt | grep '[0-9']",
  ts_read_i=10, ts_read=0,
}


function conky_todo_read(proc_num)
  local ts = os.time()

  if os.difftime(ts, todoVals.ts_read) > todoVals.ts_read_i then
    local sh = io.popen(todoVals.cmdstart..proc_num..todoVals.cmdend, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end



function conky_ratio_to_string(a,b)
    if a==nil or b==nil then return('  ') end
    if b<1000 then
        return tostring(a)..' / '..tostring(b)
    elseif b<1000000 then
        numerator=math.floor(a/1000) + math.floor(a%1000 /100)/10
        denominator=math.floor(b/1000) + math.floor(b%1000/100)/10
        return tostring(numerator)..'K / '..tostring(denominator)..'K'
    elseif b<1000000000 then 
        numerator=math.floor(a/1000000) + math.floor(a%1000000 /100000)/10
        denominator=math.floor(b/1000000) + math.floor(b%1000000/100000)/10
        return tostring(numerator)..'M / '..tostring(denominator)..'M'
    elseif b<1000000000000 then
        numerator=math.floor(a/1000000000) + math.floor(a%1000000000 /100000000)/10
        denominator=math.floor(b/1000000000) + math.floor(b%1000000000/100000000)/10
        return tostring(numerator)..'B / '..tostring(denominator)..'B'
    end 

end




function conky_prog_report(proc_num)
    if conky_todo_read(proc_num)==0 then return 0
    else
        return 100*conky_prog_read(proc_num)/conky_todo_read(proc_num)
    end
end




nameVals = {
  values=nil,
  cmd="cat /home/storms/Progress/process_name.txt",
  ts_read_i=10, ts_read=0,
}




function conky_get_process_name()
  local ts = os.time()

  if os.difftime(ts, nameVals.ts_read) > nameVals.ts_read_i then
    local sh = io.popen(nameVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 


MeganameVals = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_process_name.txt",
  ts_read_i=10, ts_read=0,
}




function conky_get_Mega_process_name()
  local ts = os.time()

  if os.difftime(ts, MeganameVals.ts_read) > MeganameVals.ts_read_i then
    local sh = io.popen(MeganameVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 


MaintodoVals = {
  values=nil,
  cmd="cat /home/storms/Progress/main_todo.txt | grep '[0-9']",
  cmd_prog="cat /home/storms/Progress/main_prog.txt | grep '[0-9']",
  ts_read_i=10, ts_read=0,
}



function conky_get_Main_todo()
  local ts = os.time()

  if os.difftime(ts, MaintodoVals.ts_read) > MaintodoVals.ts_read_i then
    local sh = io.popen(MaintodoVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end




function conky_get_Main_prog()
  local ts = os.time()

  if os.difftime(ts, MaintodoVals.ts_read) > MaintodoVals.ts_read_i then
    local sh = io.popen(MaintodoVals.cmd_prog, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end



MegatodoVals = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_todo.txt | grep '[0-9']",
  ts_read_i=10, ts_read=0,
}


function conky_get_Mega_todo()
  local ts = os.time()

  if os.difftime(ts, MegatodoVals.ts_read) > MegatodoVals.ts_read_i then
    local sh = io.popen(MegatodoVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end



MegafileVals = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_prog.txt | grep '[0-9']",
  ts_read_i=10, ts_read=0,
}


function conky_get_Mega_prog()
  local ts = os.time()

  if os.difftime(ts, MegafileVals.ts_read) > MegafileVals.ts_read_i then
    local sh = io.popen(MegafileVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end


nameVals = {
  values=nil,
  cmd="cat /home/storms/Progress/process_name.txt",
  ts_read_i=10, ts_read=0,
}




function conky_get_process_name()
  local ts = os.time()

  if os.difftime(ts, nameVals.ts_read) > nameVals.ts_read_i then
    local sh = io.popen(nameVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 



timeVals = {
  values=nil,
  cmd_main="cat /home/storms/Progress/main_runtime.txt",
  cmd_mega="cat /home/storms/Progress/mega_runtime.txt",
  cmd_overarch="cat /home/storms/Progress/overarch_runtime.txt",
  cmd_task="cat /home/storms/Progress/task_runtime.txt",
  cmd_mini="cat /home/storms/Progress/mini_runtime.txt",
  cmd_OA="cat /home/storms/Progress/OA_runtime.txt",
  cmd_SUBOA="cat /home/storms/Progress/SUBOA_runtime.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Main_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_main, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)

            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"
        end
    end

    
end



function conky_get_OA_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_OA, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)

            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"
        end
    end

    
end

function conky_get_SUBOA_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_SUBOA, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)

            seconds=math.floor((use-3600*hours - 60*minutes))

            return "( "..tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s Total)"
        end
    end

    
end




function conky_get_mini_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_mini, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)

            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"
        end
    end

    
end



function conky_get_Mega_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_mega, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)
            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"

        end
    end

    
end



function conky_get_Task_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_task, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)
            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"

        end
    end

    
end




function conky_get_Overarch_runtime()
    local ts=os.time()
    if os.difftime(ts, timeVals.ts_read) > timeVals.ts_read_i then
        local sh = io.popen(timeVals.cmd_overarch, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)
            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"

        end
    end

    
end





function conky_Main_prog_report()

    prog=conky_get_Main_prog()
    todo=conky_get_Main_todo()
    
    if todo==nil or prog==nil then return 0 end

    if todo==0 then return 0 end 

    out=100* prog/todo
    if out>100 then return 0

    else    
        return out
    end

end 




function conky_Mega_prog_report()
    if conky_get_Mega_todo()==0 then return 0
    else
        return 100* conky_get_Mega_prog()/conky_get_Mega_todo()
    end 

end
-- function conky_pyprog_read(core)


detVals = {
  values=nil,
  cmd="cat /home/storms/Progress/proc_details.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Main_details()
  local ts = os.time()

  if os.difftime(ts, detVals.ts_read) > detVals.ts_read_i then
    local sh = io.popen(detVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 'none'
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


det2Vals = {
  values=nil,
  cmd="cat /home/storms/Progress/proc_details2.txt",
  ts_read_i=10, ts_read=0,
}

function conky_get_Main_details2()
  local ts = os.time()

  if os.difftime(ts, det2Vals.ts_read) > det2Vals.ts_read_i then
    local sh = io.popen(det2Vals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end



OAdetVals = {
  values=nil,
  cmd="cat /home/storms/Progress/OA_proc_details.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_OA_details()
  local ts = os.time()

  if os.difftime(ts, OAdetVals.ts_read) > OAdetVals.ts_read_i then
    local sh = io.popen(OAdetVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end







MegadetVals = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_proc_details.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Mega_details1()
  local ts = os.time()

  if os.difftime(ts, MegadetVals.ts_read) > MegadetVals.ts_read_i then
    local sh = io.popen(MegadetVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end



MegadetVals2 = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_proc_details2.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Mega_details2()
  local ts = os.time()

  if os.difftime(ts, MegadetVals2.ts_read) > MegadetVals2.ts_read_i then
    local sh = io.popen(MegadetVals2.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


MegadetVals3 = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_proc_details3.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Mega_details3()
  local ts = os.time()

  if os.difftime(ts, MegadetVals3.ts_read) > MegadetVals3.ts_read_i then
    local sh = io.popen(MegadetVals3.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


oa_sub_bar_vals = {
  values=nil,
  cmd="cat /home/storms/Progress/oa_sub_runtime.txt",
  cmd_det="cat /home/storms/Progress/oa_sub_details.txt",
  cmd3="cat /home/storms/Progress/oa_sub_todo.txt",
  ts_read_i=10, ts_read=0,
}




function conky_get_oa_subbar_todo()
  local ts = os.time()

  if os.difftime(ts, oa_sub_bar_vals.ts_read) > oa_sub_bar_vals.ts_read_i then
    local sh = io.popen(oa_sub_bar_vals.cmd3, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end






function conky_get_oa_subbar_runtime()
    local ts=os.time()
    if os.difftime(ts, oa_sub_bar_vals.ts_read) > oa_sub_bar_vals.ts_read_i then
        local sh = io.popen(oa_sub_bar_vals.cmd, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)
            seconds=math.floor((use-3600*hours - 60*minutes))

            return "( "..tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s  Total )"

        end
    end

    
end




function conky_get_oa_subbar_detail()
  local ts = os.time()

  if os.difftime(ts, oa_sub_bar_vals.ts_read) > oa_sub_bar_vals.ts_read_i then
    local sh = io.popen(oa_sub_bar_vals.cmd_det, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end








oa_sup_bar_vals = {
  values=nil,
  cmd="cat /home/storms/Progress/oa_sup_runtime.txt",
  cmd_det="cat /home/storms/Progress/oa_sup_details.txt",
  cmd3="cat /home/storms/Progress/oa_sup_todo.txt",
  ts_read_i=10, ts_read=0,
}




function conky_get_oa_supbar_todo()
  local ts = os.time()

  if os.difftime(ts, oa_sup_bar_vals.ts_read) > oa_sup_bar_vals.ts_read_i then
    local sh = io.popen(oa_sup_bar_vals.cmd3, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end






function conky_get_oa_supbar_runtime()
    local ts=os.time()
    if os.difftime(ts, oa_sup_bar_vals.ts_read) > oa_sup_bar_vals.ts_read_i then
        local sh = io.popen(oa_sup_bar_vals.cmd, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)
            seconds=math.floor((use-3600*hours - 60*minutes))

            return "( "..tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s  Total )"

        end
    end

    
end

















Mega_subtask_vals= {
  values=nil,
  cmd="cat /home/storms/Progress/mega_subtask.txt",
  cmd2="cat /home/storms/Progress/mega_subtask_just_name.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Mega_subtask_name()
  local ts = os.time()

  if os.difftime(ts, Mega_subtask_vals.ts_read) > Mega_subtask_vals.ts_read_i then
    local sh = io.popen(Mega_subtask_vals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


function conky_get_megasub_just_name()
  local ts = os.time()

  if os.difftime(ts, Mega_subtask_vals.ts_read) > Mega_subtask_vals.ts_read_i then
    local sh = io.popen(Mega_subtask_vals.cmd2, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


OverarchNameVals = {
  values=nil,
  cmd="cat /home/storms/Progress/overarch_name.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Overarch_name()
  local ts = os.time()

  if os.difftime(ts, OverarchNameVals.ts_read) > OverarchNameVals.ts_read_i then
    local sh = io.popen(OverarchNameVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


TaskNameVals = {
  values=nil,
  cmd="cat /home/storms/Progress/task_name.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Task_name()
  local ts = os.time()

  if os.difftime(ts, TaskNameVals.ts_read) > TaskNameVals.ts_read_i then
    local sh = io.popen(TaskNameVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end

TaskNameVals = {
  values=nil,
  cmd="cat /home/storms/Progress/task_name.txt",
  ts_read_i=10, ts_read=0,
}


function conky_get_Task_name()
  local ts = os.time()

  if os.difftime(ts, TaskNameVals.ts_read) > TaskNameVals.ts_read_i then
    local sh = io.popen(TaskNameVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end




TaskdetVals = {
  values=nil,
  cmd1="cat /home/storms/Progress/task_details1.txt",
  cmd2="cat /home/storms/Progress/task_details2.txt",
  cmd3="cat /home/storms/Progress/task_details3.txt",
  cmd4="cat /home/storms/Progress/task_details4.txt",

  ts_read_i=10, ts_read=0,
}


function conky_get_Task_details1()
  local ts = os.time()

  if os.difftime(ts, TaskdetVals.ts_read) > TaskdetVals.ts_read_i then
    local sh = io.popen(TaskdetVals.cmd1, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


function conky_get_Task_details2()
  local ts = os.time()

  if os.difftime(ts, TaskdetVals.ts_read) > TaskdetVals.ts_read_i then
    local sh = io.popen(TaskdetVals.cmd2, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end



function conky_get_Task_details3()
  local ts = os.time()

  if os.difftime(ts, TaskdetVals.ts_read) > TaskdetVals.ts_read_i then
    local sh = io.popen(TaskdetVals.cmd3, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end





function conky_get_Task_details4()
  local ts = os.time()

  if os.difftime(ts, TaskdetVals.ts_read) > TaskdetVals.ts_read_i then
    local sh = io.popen(TaskdetVals.cmd4, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


OverdetVals = {
  values=nil,
  cmd="cat /home/storms/Progress/overarch_message.txt",
  ts_read_i=10, ts_read=0,
}

function conky_get_Overarch_details()
  local ts = os.time()

  if os.difftime(ts, OverdetVals.ts_read) > OverdetVals.ts_read_i then
    local sh = io.popen(OverdetVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end


OAVals = {
  values=nil,
  cmd="cat /home/storms/Progress/OA_name.txt",
  cmd2="cat /home/storms/Progress/OA_todo.txt",
  cmd3="cat /home/storms/Progress/OA_prog.txt",
  ts_read_i=10, ts_read=0,
}

function conky_get_OA_name()
  local ts = os.time()

  if os.difftime(ts, OAVals.ts_read) > OAVals.ts_read_i then
    local sh = io.popen(OAVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end



function conky_get_OA_todo()
  local ts = os.time()

  if os.difftime(ts, OAVals.ts_read) > OAVals.ts_read_i then
    local sh = io.popen(OAVals.cmd2, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end




function conky_get_OA_prog()
  local ts = os.time()

  if os.difftime(ts, OAVals.ts_read) > OAVals.ts_read_i then
    local sh = io.popen(OAVals.cmd3, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end





function conky_OA_prog_report()

    out=100* conky_get_OA_prog()/conky_get_OA_todo()
    if out>100 then return 0

    else    
        return math.floor(out)
    end

end


megasubvals = {
  values=nil,
  cmd="cat /home/storms/Progress/mega_sub_runtime.txt",
  cmd2="cat /home/storms/Progress/mega_sub_prog.txt",
  cmd3="cat /home/storms/Progress/mega_sub_todo.txt",
  ts_read_i=10, ts_read=0,
}



function conky_get_megasub_todo()
  local ts = os.time()

  if os.difftime(ts, megasubvals.ts_read) > megasubvals.ts_read_i then
    local sh = io.popen(megasubvals.cmd3, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end




function conky_get_megasub_prog()
  local ts = os.time()

  if os.difftime(ts, megasubvals.ts_read) > megasubvals.ts_read_i then
    local sh = io.popen(megasubvals.cmd2, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end

function conky_get_megasub_runtime()
    local ts=os.time()
    if os.difftime(ts, megasubvals.ts_read) > megasubvals.ts_read_i then
        local sh = io.popen(megasubvals.cmd, 'r')
        if sh==nil then 
            sh:close()
            return tostring(0)
        else
            local use = sh:read('*number')
            sh:close()
            hours=math.floor(use/3600)
            minutes=math.floor((use - 3600*hours)/60)
            seconds=math.floor((use-3600*hours - 60*minutes))

            return tostring(hours).." h  "..tostring(minutes).." m  "..tostring(seconds).." s"

        end
    end
end


function conky_get_megasub_prog_report()

    out=100* conky_get_megasub_prog()/conky_get_megasub_todo()
    if out>100 then return 0

    else    
        return math.floor(out)
    end

end



function conky_get_megasub_prog_frac()
  maintodo=tonumber(conky_get_megasub_todo())
  mainprog=tonumber(conky_get_megasub_prog())
  return conky_ratio_to_string(mainprog,maintodo)
end 



SUBOAVals = {
  values=nil,
  cmd="cat /home/storms/Progress/SUBOA_name.txt",
  cmd2="cat /home/storms/Progress/SUBOA_todo.txt",
  cmd3="cat /home/storms/Progress/SUBOA_prog.txt",
  ts_read_i=10, ts_read=0,
}

function conky_get_SUBOA_name()
  local ts = os.time()

  if os.difftime(ts, SUBOAVals.ts_read) > OAVals.ts_read_i then
    local sh = io.popen(SUBOAVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        outpout=tostring(output)
        return string.gsub(output, "\n", "") 

    end
  end

  return ''
end



function conky_get_SUBOA_todo()
  local ts = os.time()

  if os.difftime(ts, SUBOAVals.ts_read) > SUBOAVals.ts_read_i then
    local sh = io.popen(SUBOAVals.cmd2, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end




function conky_get_SUBOA_prog()
  local ts = os.time()

  if os.difftime(ts, SUBOAVals.ts_read) > SUBOAVals.ts_read_i then
    local sh = io.popen(SUBOAVals.cmd3, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end
























function conky_SUBOA_prog_report()

    out=100* conky_get_SUBOA_prog()/conky_get_SUBOA_todo()
    if out>100 then return 0

    else    
        return math.floor(out)
    end

end




MiniVals = {
  values=nil,
  cmd="cat /home/storms/Progress/show_mini.txt",
  cmd_name="cat /home/storms/Progress/mini_process_name.txt",
  cmd_prog="cat /home/storms/Progress/mini_prog.txt",
  cmd_todo="cat /home/storms/Progress/mini_todo.txt",
  cmd_runtime="cat /home/storms/Progress/mini_runtime.txt",
  cmd_det="cat /home/storms/Progress/mini_proc_details.txt",
  cmd_det2="cat /home/storms/Progress/mini_proc_details2.txt",
  ts_read_i=10, ts_read=0,
}




function conky_get_mini()
  local ts = os.time()

  if os.difftime(ts, MiniVals.ts_read) > MiniVals.ts_read_i then
    local sh = io.popen(MiniVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end

 

if conky_get_mini()==1 then
    color50="0xC0C0C0"
    rev_alpha=0.2
else
    color50=color44
    rev_alpha=0.6

end 


function conky_get_mini_name()
  local ts = os.time()

  if os.difftime(ts, MiniVals.ts_read) > MiniVals.ts_read_i then
    local sh = io.popen(MiniVals.cmd_name, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 


function conky_get_mini_detail()
  local ts = os.time()

  if os.difftime(ts, MiniVals.ts_read) > MiniVals.ts_read_i then
    local sh = io.popen(MiniVals.cmd_det, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 

function conky_get_mini_detail2()
  local ts = os.time()

  if os.difftime(ts, MiniVals.ts_read) > MiniVals.ts_read_i then
    local sh = io.popen(MiniVals.cmd_det2, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 

function conky_get_mini_prog()
  local ts = os.time()

  if os.difftime(ts, MiniVals.ts_read) > MiniVals.ts_read_i then
    local sh = io.popen(MiniVals.cmd_prog, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end


function conky_get_mini_todo()
  local ts = os.time()

  if os.difftime(ts, MiniVals.ts_read) > MiniVals.ts_read_i then
    local sh = io.popen(MiniVals.cmd_todo, 'r')
    if sh==nil then 
        sh:close()
        return 0
    else
        local output = sh:read('*number')
        sh:close()
        return tonumber(output)
    end
  end

  return ''
end

function conky_mini_prog_report()

    todo=conky_get_mini_todo()
    prog=conky_get_mini_prog()

    if todo==nil or prog==nil then return 0 end 
    if todo==0 then return 0

    else
        out=100* prog/todo
        if out>100 then return 0

        else    
            return math.floor(out)
        end

    end 
end


--[[------------------------------------------------Functions for Conky Display Text -----------------------------------------------------------------]]


function conky_main_process_name()

  progname=conky_get_process_name()
  return string.gsub(tostring(progname),'%s','    ')

end

function conky_main_proc_prog_frac()
  maintodo=tonumber(conky_get_Main_todo())
  mainprog=tonumber(conky_get_Main_prog())
  return conky_ratio_to_string(mainprog,maintodo)
end 


function conky_main_proc_prog_per()
  return tostring(math.floor(conky_Main_prog_report()))
end



function conky_main_proc_runtime()
  return conky_get_Main_runtime()
end 

function conky_main_proc_details1()
  return conky_get_Main_details()
end 


function conky_main_proc_details2()
  return conky_get_Main_details2()
end 

function conky_mini_prog_frac()
  return conky_ratio_to_string(conky_get_mini_prog(),conky_get_mini_todo())
end 

function conky_OA_prog_frac()
  todo=conky_get_OA_todo()
  prog=conky_get_OA_prog()
  out=conky_ratio_to_string(prog,todo)
  return out
end



function conky_mega_prog_frac()
  todo=conky_get_Mega_todo()
  prog=conky_get_Mega_prog()
  out=conky_ratio_to_string(prog,todo)
  return out
end



function conky_show_main()
  if string.match(conky_main_process_name(),'none') then return 0
  else return 1 
  end 
end 


function conky_show_mini()
  if string.match(conky_get_mini_name(),'none') then return 0
  else return 1 
  end 
end 

function conky_show_OA()
  if string.match(conky_get_OA_name(),'none') then return 0
  else return 1 
  end 
end 



function conky_averaging_subthreads()
  if string.match(conky_main_process_name(),'average') and string.match(conky_main_process_name(),'subthread') then return 1
  else return 0 
  end 
end 


SubThreadVals = {
  values=nil,
  cmd="cat /home/storms/Progress/running_subthreads.txt",
  ts_read_i=10, ts_read=0,
}



function conky_get_active_subthreads()
  local ts = os.time()

  if os.difftime(ts, SubThreadVals.ts_read) > SubThreadVals.ts_read_i then
    local sh = io.popen(SubThreadVals.cmd, 'r')
    if sh==nil then 
        sh:close()
        return ''
    else
        local output = sh:read('*all')
        sh:close()
        output=string.gsub(output, "\n", "") 
        return output
    end
  end

  return ''
end 



function conky_show_main_details1()
  if string.match(conky_main_proc_details1(),"none") then return 0 
  else return 1 
  end 
end 

function conky_show_task()
  if string.match(conky_get_Mega_process_name(),'none') then return 0
  else return 1 
  end 
end 



function conky_show_mini_detail()
  if string.match(conky_get_mini_detail(),'none') then return 0
  else return 1 
  end 
end 





function conky_show_Mega_details()
  if string.match(conky_get_Mega_details1(),"none") then return 0 
  else return 1 
  end 
end 


function conky_show_OA_details()
  if string.match(conky_get_OA_details(),"none") then return 0 
  else return 1 
  end 
end 


function conky_show_Mega_subtask()
  if string.match(conky_get_Mega_subtask_name(),"none") then return 0 
  else return 1 
  end 
end 



function conky_megasub_just_name()
  if string.match(conky_get_megasub_just_name(), "yes") then return 1 
  else return 0 
  end 
end 




function conky_show_main_details2()
  if string.match(conky_main_proc_details2(),"none") then return 0 
  else return 1 
  end 
end 




function conky_main_name_len()
  main_name=conky_main_process_name()
  return string.len(main_name)
end


first_cut=27
second_cut=25 

function conky_main_process_name1()
  main_name=conky_main_process_name().." "
  length=string.len(main_name)
  backward_count=length - first_cut
  rev_split_at=string.find(string.reverse(main_name)," ",backward_count)
  split_at = length - rev_split_at+1
  return string.sub(main_name,1,split_at)
end 


function conky_main_process_name2()
  main_name=conky_main_process_name().." "
  length=string.len(main_name)
  backward_count=length - first_cut
  rev_split_at=string.find(string.reverse(main_name)," ",backward_count)
  split_at =  length - rev_split_at+1
  next=ltrim(string.sub(main_name,split_at))
  step=string.find(next," ", second_cut)
  return string.sub(next,1,step)

end 

function conky_main_process_name3()
  main_name=conky_main_process_name().." "
  length=string.len(main_name)
  backward_count=length - first_cut
  rev_split_at=string.find(string.reverse(main_name)," ",backward_count)
  split_at = length - rev_split_at+1
  next=ltrim(string.sub(main_name,split_at))
  split_at=string.find(next," ",second_cut)+1
  return ltrim(string.sub(next,split_at))

end 

function ltrim(s)
  return s:match'^%s*(.*)'
end



function conky_get_mega_name_len()
  mega_name=conky_get_Mega_process_name()
  return string.len(mega_name)

end 

function conky_mega_name1()
  mega_name=conky_get_Mega_process_name()
  split_at=string.find(mega_name," ",30)
  return string.sub(mega_name,1,split_at)
end 



function conky_mega_name2()
  mega_name=conky_get_Mega_process_name()
  split_at=string.find(mega_name," ",30)+1
  return ltrim(string.sub(mega_name,split_at))
end 



--[[Use conky_OA_prog_report--]]


--[[------------------------------------------------End Reading Functions -----------------------------------------------------------------]]











--[[------------------------------------------------Text Drawing Function-----------------------------------------------------------------]]




function conky_just_text()
    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
    
    local cr=cairo_create(cs)   
    
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)

    if update_num>5 then
        progname=conky_get_process_name()

        progVal=tonumber(conky_Main_prog_report())
      
        megaoverarch_name=conky_get_OA_name()
        suboverarch_name=conky_get_SUBOA_name()

        if string.match(megaoverarch_name,'none') then
            runfntsize=35
            runfntsize2=20
        else
           runfntsize=30
           runfntsize2=20
        end




--[[------------------------------------------------Mega Overarch Section-----------------------------------------------------------------]]


        if string.match(megaoverarch_name,'none') then
                u=5
            else

                draw_text(cr,    {
                text="Overarching:", 
                from={x=-190,y=500},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=35,
                bold=false,
                italic=false,
                alpha=1,
                draw_function = draw_static_text,
                })




                draw_text(cr,    {
                text="Progress:               "..conky_ratio_to_string(conky_get_OA_prog(),conky_get_OA_todo())..'   '..'('..conky_OA_prog_report()..'%)', 
                from={x=-190,y=530},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=17,
                bold=false,
                italic=false,
                alpha=1,
                draw_function = draw_static_text,
                })




                draw_text(cr,    {
                text="Runtime:", 
                from={x=-190,y=555},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=17,
                bold=false,
                italic=false,
                alpha=1,
                draw_function = draw_static_text,
                })

                draw_text(cr,    {
                text=conky_get_OA_runtime(), 
                from={x=51,y=555},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=17,
                bold=false,
                italic=false,
                alpha=1,
                draw_function = draw_static_text,
                })


                if conky_get_OA_details()=='none' then u=5

                else
                    draw_text(cr,    {
                    text="Details:                  "..conky_get_OA_details(), 
                    from={x=-190,y=580},
                    color = color1,
                    rotation_angle=0,
                    font="Federation",
                    font_size=17,
                    bold=false,
                    italic=false,
                    alpha=1,
                    draw_function = draw_static_text,
                    })
                end 



                draw_text(cr,    {
                text=megaoverarch_name, 
                from={x=123,y=500},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=25,
                bold=false,
                italic=false,
                alpha=1,
                draw_function = draw_static_text,
                })
        end
--[[---------------------------------------------SubOA Section---------------------------------------------------------------------------------------]]

--[[        if string.match(suboverarch_name,'none') then
            u=5
        else
            
            draw_text(cr,    {
            text="Sub-Overarching:", 
            from={x=-190,y=630},
            color = color7,
            rotation_angle=0,
            font="Federation",
            font_size=25,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })



            draw_text(cr,    {
            text="Progress:                 "..conky_ratio_to_string(conky_get_SUBOA_prog(),conky_get_SUBOA_todo())..'   '..'('..conky_SUBOA_prog_report()..'%)', 
            from={x=-190,y=660},
            color = color7,
            rotation_angle=0,
            font="Federation",
            font_size=15,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })



            draw_text(cr,    {
            text="Runtime:                  "..conky_get_SUBOA_runtime(), 
            from={x=-190,y=680},
            color = color7,
            rotation_angle=0,
            font="Federation",
            font_size=15,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })

            draw_text(cr,    {
            text=suboverarch_name, 
            from={x=123,y=630},
            color = color7,
            rotation_angle=0,
            font="Federation",
            font_size=20,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })

        end 
--]]
--[[---------------------------------------------Overarch Section---------------------------------------------------------------------------------------]]


--[[        overarch_name=conky_get_Overarch_name()
        if string.match(overarch_name,'none') then
            u=5
        else


            draw_text(cr,    {
            text="RUNNING:", 
            from={x=-190,y=735},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=runfntsize,
            bold=false,
            italic=false,
            alpha=0.5,
            draw_function = draw_static_text,
            })

            draw_text(cr,    {
            text="Total Runtime:   "..conky_get_Overarch_runtime(), 
            from={x=-190,y=767},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=runfntsize2,
            bold=false,
            italic=false,
            alpha=0.5,
            draw_function = draw_static_text,
            })


            draw_text(cr,    {
            text=overarch_name, 
            from={x=40,y=735},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=runfntsize2,
            bold=false,
            italic=false,
            alpha=0.5,
            draw_function = draw_static_text,
            })

        overarch_det=conky_get_Overarch_details()

            if string.match(overarch_det,'none') then
                u=5
            else

                draw_text(cr,    {
                text="Details: "..overarch_det, 
                from={x=-190,y=795},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=20,
                bold=false,
                italic=false,
                alpha=0.5,
                draw_function = draw_static_text,
                })


            end 
        end 
--]]
--[[-----------------------------------------------Task Section-------------------------------------------------------------------------------------]]



--[[    taskname=conky_get_Task_name()
        if string.match(taskname,'none') then
            u=5
        else

            draw_text(cr,    {
            text="Current Task: ", 
            from={x=-190,y=835},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=20,
            bold=false,
            italic=false,
            alpha=0.3,
            draw_function = draw_static_text,
            })


            draw_text(cr,    {
            text=conky_get_Task_name(), 
            from={x=30,y=835},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=20,
            bold=false,
            italic=false,
            alpha=0.3,
            draw_function = draw_static_text,
            })


            draw_text(cr,    {
            text="Task Runtime: ", 
            from={x=-190,y=860},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=20,
            bold=false,
            italic=false,
            alpha=0.3,
            draw_function = draw_static_text,
            })



            draw_text(cr,    {
            text=conky_get_Task_runtime(), 
            from={x=30,y=860},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=20,
            bold=false,
            italic=false,
            alpha=0.3,
            draw_function = draw_static_text,
            })



            TaskDetails1=conky_get_Task_details1()
            TaskDetails2=conky_get_Task_details2()         
            TaskDetails3=conky_get_Task_details3()
            TaskDetails4=conky_get_Task_details4()


            if string.match(TaskDetails1,'none') then
                u=5
            else


                draw_text(cr,    {
                text="Details: ", 
                from={x=-190,y=890},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=20,
                bold=false,
                italic=false,
                alpha=0.3,
                draw_function = draw_static_text,
                })




                draw_text(cr,    {
                text=TaskDetails1, 
                from={x=30,y=890},
                color = color47,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=0.3,
                draw_function = draw_static_text,
                })

            end 

            if string.match(TaskDetails2,'none') then
                u=5
            else
                draw_text(cr,    {
                text=TaskDetails2, 
                from={x=30,y=905},
                color = color47,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=0.3,
                draw_function = draw_static_text,
                })

            end 




            if string.match(TaskDetails3,'none') then
                u=5
            else
                draw_text(cr,    {
                text=TaskDetails3, 
                from={x=30,y=922},
                color = color47,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=0.3,
                draw_function = draw_static_text,
                })

            end 






            if string.match(TaskDetails4,'none') then
                u=5
            else
                draw_text(cr,    {
                text=TaskDetails4, 
                from={x=30,y=937},
                color = color47,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=0.3,
                draw_function = draw_static_text,
                })

            end 



        end --]]


--[[--------------------------------Main process section----------------------------------------------------------------------------------------------------]]



        if string.match(progname,'none') then
            u=5
        else

     --[[       draw_text(cr,    {
            text="Subprocess: ", 
            from={x=-240,y=830},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=45,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })


            draw_text(cr,    {
            text="Subprocess: ", 
            from={x=-243,y=833},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=45,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })


            maintodo=tonumber(conky_get_Main_todo())
            mainprog=tonumber(conky_get_Main_prog())
            Megatodo=tonumber(conky_get_Mega_todo())
            Megaprog=tonumber(conky_get_Mega_prog())
            MegaName=conky_get_Mega_process_name()

            fntsize=30



            y1=885
            y2=930
            y3=970
            y4=1092
            y5=1119


            draw_text(cr,    {
            text="Name:      ",
            from={x=-240,y=y1},
            color = color1,
            rotation_angle=0,
            font="Michroma",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })


            dynColor="0xFF6AFF"
            dynAlpha=1



            draw_text(cr,    {
            text=string.gsub(tostring(progname),'%s','    '), 
            from={x=-10,y=y1},
            color = dynColor,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=true,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })





            draw_text(cr,    {
            from={x=-10,y=y2},
            color = dynColor,
            text=conky_ratio_to_string(mainprog,maintodo)..'  ( '..tostring(math.floor(conky_Main_prog_report())).."% )" ,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=true,
            italic=false,
            alpha=dynAlpha,
            draw_function = draw_static_text,
            })

            draw_text(cr,    {
            from={x=-240,y=y2},
            color = color1,
            text='Progress:  ' ,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=0.8,
            draw_function = draw_static_text,
            })


            draw_text(cr,    {
            text=conky_get_Main_runtime(),
            from={x=-10,y=y3},
            color = dynColor,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=true,
            italic=false,
            alpha=dynAlpha,
            draw_function = draw_static_text,
            })

            draw_text(cr,    {
            text='Runtime:    ',
            from={x=-240,y=y3},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=0.8,
            draw_function = draw_static_text,
            })



            MainDetails=conky_get_Main_details()

            if string.match(MainDetails,'none') then
                u=5
            else
                draw_text(cr,    {
                text=MainDetails ,
                from={x=-10,y=y4},
                color = dynColor,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=dynAlpha,
                draw_function = draw_static_text,
                })


                draw_text(cr,    {
                text="Details: ",
                from={x=-240,y=y4},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=20,
                bold=false,
                italic=false,
                alpha=0.8,
                draw_function = draw_static_text,
                })
            end 


            MainDetails2=conky_get_Main_details2()

            if string.match(MainDetails2,'none') then
                u=5
            else
                draw_text(cr,    {
                text=MainDetails2,
                from={x=-10,y=y5},
                color = dynColor,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=0.8,
                draw_function = draw_static_text,
                })
            end

--]]


        end
--[[----------------------------------Mini Section--------------------------------------------------------------------------------------------------]]


        minitodo=tonumber(conky_get_mini_todo())
        miniprog=tonumber(conky_get_mini_prog())
        mininame=tostring(conky_get_mini_name())
        miniruntime=conky_get_mini_runtime()


        if conky_get_mini()==1 then 
--[[            if string.match(MegaName,'none') then
                y1=1215
                y2=1240
                y3=1265
                y4=1292
                y5=1319
            else
                y1=1315
                y2=1345
                y3=1370
                y4=1395
                y5=1415
            end --]]


           --[[ draw_text(cr,    {
            text="Mini:      ",
            from={x=-190,y=y1},
            color = color1,
            rotation_angle=0,
            font="Michroma",
            font_size=20,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })



            draw_text(cr,    {
            text=string.gsub(tostring(mininame),'%s','    '), 
            from={x=-50,y=y1},
            color = color44,
            rotation_angle=0,
            font="Michroma",
            font_size=20,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })

            dynColor=color44
            dynAlpha=0.9



            draw_text(cr,    {
            from={x=-50,y=y2},
            color = dynColor,
            text=conky_ratio_to_string(miniprog,minitodo)..'  ( '..tostring(math.floor(conky_mini_prog_report())).."% )" ,
            rotation_angle=0,
            font="Federation",
            font_size=20,
            bold=false,
            italic=false,
            alpha=dynAlpha,
            draw_function = draw_static_text,
            })

            draw_text(cr,    {
            from={x=-190,y=y2},
            color = color1,
            text='Progress:  ' ,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=0.8,
            draw_function = draw_static_text,
            })


            draw_text(cr,    {
            text=miniruntime,
            from={x=-50,y=y3},
            color = dynColor,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=dynAlpha,
            draw_function = draw_static_text,
            })

            draw_text(cr,    {
            text='Runtime:    ',
            from={x=-190,y=y3},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=0.8,
            draw_function = draw_static_text,
            })

        else u=5 --]]


          mini_lines_table = { 

              {name='line 1',
              from={x=2102,y=1220},
              to={x=2853,y=1220},
              color = "0x000000",
              alpha = 0.90,
              thickness = 4,
              graduated = false,
              number_graduation=0,
              space_between_graduation=1,
              draw_function = draw_line,
          }, 

          }



          for i in pairs(mini_lines_table) do
              draw_line(cr,mini_lines_table[i])
          end
        end 




--[[--------------------Mega Section----------------------------------------------------------------------------------------------------------------]]


       --[[ if string.match(MegaName,'none') then
            u=5
        else
            if conky_get_mini()==1 then
                meg_color="0xC0C0C0"
                meg_alpha=0.3
            else
                meg_color=color44
                meg_alpha=0.8
            end 

            fntsize=20

            draw_text(cr,    {
            text="Mega:    ", 
            from={x=-190,y=1015},
            color = color1,
            rotation_angle=0,
            font="Michroma",
            font_size=20,
            bold=false,
            italic=false,
            alpha=1,
            draw_function = draw_static_text,
            })




            draw_text(cr,    {
            text=tostring(MegaName), 
            from={x=-50,y=1015},
            color = meg_color,
            rotation_angle=0,
            font="Michroma",
            font_size=20,
            bold=false,
            italic=false,
            alpha=meg_alpha,
            draw_function = draw_static_text,
            })




            draw_text(cr,    {
            text="Progress:   ",
            from={x=-190,y=1040},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=0.8,
            draw_function = draw_static_text,
            })

           draw_text(cr,    {
            text=conky_ratio_to_string(Megaprog,Megatodo),
            from={x=-50,y=1040},
            color = meg_color,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=meg_alpha,
            draw_function = draw_static_text,
            })



            -- draw_text(cr,    {
            -- text=""..tostring(math.floor(conky_Mega_prog_report())).."%",
            -- from={x=940,y=1230},
            -- color = color44,
            -- rotation_angle=0,
            -- font="Federation",
            -- font_size=20,
            -- bold=false,
            -- italic=false,
            -- alpha=0.4,
            -- draw_function = draw_static_text,
            -- })

            draw_text(cr,    {
            text='Runtime: ',
            from={x=-190,y=1065},
            color = color1,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=0.8,
            draw_function = draw_static_text,
            })



            draw_text(cr,    {
            text=conky_get_Mega_runtime(),
            from={x=-50,y=1065},
            color = meg_color,
            rotation_angle=0,
            font="Federation",
            font_size=fntsize,
            bold=false,
            italic=false,
            alpha=meg_alpha,
            draw_function = draw_static_text,
            })




            MegaDetails=conky_get_Mega_details()

            if string.match(MegaDetails,'none') then
                u=5
            else

                draw_text(cr,    {
                text=MegaDetails ,
                from={x=-50,y=1092},
                color = meg_color,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=meg_alpha,
                draw_function = draw_static_text,
                })


                draw_text(cr,    {
                text="Details: ",
                from={x=-190,y=1092},
                color = color1,
                rotation_angle=0,
                font="Federation",
                font_size=20,
                bold=false,
                italic=false,
                alpha=0.8,
                draw_function = draw_static_text,
                })
            end 
        

            MegaDetails2=conky_get_Mega_details2()

            if string.match(MegaDetails2,'none') then
                u=5
            else

                draw_text(cr,    {
                text=MegaDetails2,
                from={x=-50,y=1108},
                color = meg_color,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=meg_alpha,
                draw_function = draw_static_text,
                })
            end 

            MegaDetails3=conky_get_Mega_details3()

            if string.match(MegaDetails3,'none') then
                u=5
            else

                draw_text(cr,    {
                text=MegaDetails3,
                from={x=-50,y=1123},
                color = meg_color,
                rotation_angle=0,
                font="Federation",
                font_size=15,
                bold=false,
                italic=false,
                alpha=meg_alpha,
                draw_function = draw_static_text,
                })
            end 



        end--]]

        
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end




















function draw_text(display, element)
      x=element.from.x + 700
      cairo_save(display)
      cairo_move_to (display,x,element.from.y)
      cairo_rotate(display,element.rotation_angle* (math.pi / 180))
      cairo_set_source_rgba(display,hexa_to_rgb(element.color, element.alpha))
      cairo_set_font_size(display, element.font_size)
      local font_slant = CAIRO_FONT_SLANT_NORMAL
      if element.italic then
        font_slant=CAIRO_FONT_SLANT_ITALIC
      end
      local font_weight = CAIRO_FONT_WEIGHT_NORMAL
      if element.bold then
        font_weight=CAIRO_FONT_WEIGHT_BOLD
      end
      cairo_select_font_face(display,element.font,font_slant,font_weight)

      cairo_show_text(display,element.text)

      cairo_restore(display)
      cairo_stroke(display)
end



function hexa_to_rgb(color, alpha)
    -- ugh, whish this wans't an oneliner
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
end


function draw_line(display, element)
    -- draw a line

    -- deltas for x and y (cairo expects a point and deltas for both axis)
    local x_side = element.to.x - element.from.x -- not abs! because they are deltas
    local y_side = element.to.y - element.from.y -- and the same here
    local from_x =element.from.x
    local from_y = element.from.y

    if not element.graduated then
      -- draw line
      cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
      cairo_set_line_width(display, element.thickness);
      cairo_move_to(display, element.from.x, element.from.y);
      cairo_rel_line_to(display, x_side, y_side);
      cairo_set_line_cap(display, CAIRO_LINE_CAP_ROUND)

    else
      -- draw graduated line
      cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
      cairo_set_line_width(display, element.thickness);
      local space_graduation_x = (x_side-x_side/element.space_between_graduation+1)/element.number_graduation
      local space_graduation_y =(y_side-y_side/element.space_between_graduation+1)/element.number_graduation
      local space_x = x_side/element.number_graduation-space_graduation_x
      local space_y = y_side/element.number_graduation-space_graduation_y

      for i=1,element.number_graduation do
          cairo_move_to(display,from_x,from_y)
          from_x=from_x+space_x+space_graduation_x
          from_y=from_y+space_y+space_graduation_y
          cairo_rel_line_to(display,space_x,space_y)
      end
    end
    cairo_stroke(display)
end





--[[
d88888b d8b   db d8888b.      d888888b d88888b db    db d888888b      d8888b. d8888b.  .d8b.  db   d8b   db d888888b d8b   db  d888b
88'     888o  88 88  `8D      `~~88~~' 88'     `8b  d8' `~~88~~'      88  `8D 88  `8D d8' `8b 88   I8I   88   `88'   888o  88 88' Y8b
88ooooo 88V8o 88 88   88         88    88ooooo  `8bd8'     88         88   88 88oobY' 88ooo88 88   I8I   88    88    88V8o 88 88
88~~~~~ 88 V8o88 88   88         88    88~~~~~  .dPYb.     88         88   88 88`8b   88~~~88 Y8   I8I   88    88    88 V8o88 88  ooo
88.     88  V888 88  .8D         88    88.     .8P  Y8.    88         88  .8D 88 `88. 88   88 `8b d8'8b d8'   .88.   88  V888 88. ~8~
Y88888P VP   V8P Y8888D'         YP    Y88888P YP    YP    YP         Y8888D' 88   YD YP   YP  `8b8' `8d8'  Y888888P VP   V8P  Y888P





--]]









function conky_main()
    --[[conky_just_text()--]]
end
