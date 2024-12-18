#!/system/bin/sh
# service based on mvast tweak 
# don't delete anything here

writeLog() {
    local log_message="$1"
    local log_file="/storage/emulated/0/MvastUniversal.log"

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] $log_message" >> "$log_file"
}

writeLog "[ 𝗠𝗩𝗔𝗦𝗧 𝗥𝗘𝗩𝗢𝗟𝗨𝗧𝗜𝗢𝗡 ]"
writeLog "[ 𝗟𝗢𝗚 𝗜𝗡𝗙𝗢𝗥𝗠𝗔𝗧𝗜𝗢𝗡 ]"
writeLog " "

write() {
  if [[ ! -f "$1" ]]; then
    echo "$1 doesn't exist, skipping..."
    return 1
	fi

  local curval=$(cat "$1" 2> /dev/null)
	
  if [[ "$curval" == "$2" ]]; then
    echo "$1 is already set to $2, skipping..."
	return 1
  fi

  chmod +w "$1" 2> /dev/null

   if ! echo "$2" > "$1" 2> /dev/null
   then
     echo "[!] Failed: $1 -> $2"
	 return 0
   fi

  echo "$1 $curval -> $2"
}

SCHED_PERIOD_LATENCY="$((1 * 1000 * 1000))"

SCHED_PERIOD_BALANCE="$((4 * 1000 * 1000))"

SCHED_PERIOD_BATTERY="$((8 * 1000 * 1000))"

SCHED_PERIOD_THROUGHPUT="$((10 * 1000 * 1000))"

SCHED_TASKS_LATENCY="10"

SCHED_TASKS_BATTERY="4"

SCHED_TASKS_BALANCE="8"

SCHED_TASKS_THROUGHPUT="6"

UINT_MAX="4294967295"

for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
do
  if [ -d "$gpul" ]; then
    gpu=$gpul
  fi
done

for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
do
  if [ -d "$gpul1" ]; then
    gpu=$gpul1
  fi
done

for gpul2 in /sys/devices/*.mali
do
  if [ -d "$gpul2" ]; then
    gpu=$gpul2
  fi
done

for gpul3 in /sys/devices/platform/*.gpu
do
  if [ -d "$gpul3" ]; then
    gpu=$gpul3
  fi
done
        
for gpul4 in /sys/devices/platform/mali-*.0
do
  if [ -d "$gpul4" ]; then
    gpu=$gpul4
  fi
done

if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
  gpu="/sys/class/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
  gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/gpusysfs" ]; then
  gpu="/sys/devices/platform/gpusysfs"
elif [ -d "/sys/devices/platform/mali.0" ]; then
  gpu="/sys/devices/platform/mali.0"
fi

for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq
do
  if [ -d "$gpul" ]; then
    gpug=$gpul
  fi
done

for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq
do
  if [ -d "$gpul1" ]; then
    gpug=$gpul1
  fi
done

for gpul2 in /sys/devices/platform/*.gpu
do
  if [ -d "$gpul2" ]; then
    gpug=$gpul2
  fi
done

if [ -d "/sys/class/kgsl/kgsl-3d0/devfreq" ]; then
  gpug="/sys/class/kgsl/kgsl-3d0/devfreq"
elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq" ]; then
  gpug="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq"
elif [ -d "/sys/devices/platform/gpusysfs" ]; then
  gpug="/sys/devices/platform/gpusysfs"
elif [ -d "/sys/module/mali/parameters" ]; then
  gpug="/sys/module/mali/parameters"		
elif [ -d "/sys/kernel/gpu" ]; then
  gpug="/sys/kernel/gpu"
fi
	
for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
do
  if [ -d "$gpul" ]; then
    gpum=$gpul
  fi
done

for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
do
  if [ -d "$gpul1" ]; then
    gpum=$gpul1
  fi
done

if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
  gpum="/sys/class/kgsl/kgsl-3d0"
elif [ -d "/sys/kernel/gpu" ]; then
  gpum="/sys/kernel/gpu"
fi

# Variable to GPU model
if [[ -e $gpum/gpu_model ]]; then
  GPU_MODEL=$(cat "$gpum"/gpu_model | awk '{print $1}')
fi
if [[ -e $gpug/gpu_governor ]]; then
  GPU_GOVERNOR=$(cat "$gpug"/gpu_governor)
elif [[ -e $gpug/governor ]]; then
  GPU_GOVERNOR=$(cat "$gpug"/governor)
fi

if [[ -e $gpu/min_pwrlevel ]]; then
  gpuminpl=$(cat "$gpu"/min_pwrlevel)
  gpupl=$((gpuminpl + 1))
fi

gpumx=$(cat "$gpu"/devfreq/available_frequencies | awk -v var="$gpupl" '{print $var}')

if [[ $gpumx != $(cat "$gpu"/max_gpuclk) ]]; then
  gpumx=$(cat "$gpu"/devfreq/available_frequencies | awk '{print $1}')
fi

for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  CPU_GOVERNOR=$(cat "$cpu"/scaling_governor)
done
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
  cpumxfreq=$(cat "$cpu"/scaling_max_freq)
  cpumxfreq2=$(cat "$cpu"/cpuinfo_max_freq)

  if [[ $cpumxfreq2 > $cpumxfreq ]]; then
    cpumxfreq=$cpumxfreq2
  fi
done

cpumfreq=$((cpumxfreq / 2))

gpufreq=$(cat "$gpu"/max_gpuclk)

gpumfreq=$((gpufreq / 2))

  # Disable perfd and mpdecision
  stop perfd
  stop mpdecision

renice -n -5 $(pgrep system_server)
  renice -n -5 $(pgrep com.miui.home)
  renice -n -5 $(pgrep launcher)
  renice -n -5 $(pgrep lawnchair)
  renice -n -5 $(pgrep home)
  renice -n -5 $(pgrep watchapp)
  renice -n -5 $(pgrep trebuchet)
  renice -n -1 $(pgrep dialer)
  renice -n -1 $(pgrep keyboard)
  renice -n -1 $(pgrep inputmethod)
  renice -n -9 $(pgrep fluid)
  renice -n -10 $(pgrep composer)
  renice -n -1 $(pgrep com.android.phone)
  renice -n -10 $(pgrep surfaceflinger)
  renice -n 1 $(pgrep kswapd0)
  renice -n 1 $(pgrep ksmd)
  renice -n -6 $(pgrep msm_irqbalance)
  renice -n -9 $(pgrep kgsl_worker)
  renice -n 6 $(pgrep android.gms)
  
  
  writeLog "[*] DISABLED MPDECISION AND PERFD "
  
  
  # Disable logd and statsd to reduce overhead.
  stop logd
  stop statsd
  
  
  writeLog "[*] DISABLED STATSD AND LOGD "
  
  
  if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
  	write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
  	
  	writeLog "[*] TWEAKED STUNE BOOST "
  	
  fi
  
  for corectl in /sys/devices/system/cpu/cpu*/core_ctl
  do
  	if [[ -e "${corectl}/enable" ]]; then
  		write "${corectl}/enable" "0"
  	elif [[ -e "${corectl}/disable" ]]; then
  		write "${corectl}/disable" "1"
  	fi
  done
  
  
  writeLog "[*] DISABLED CORE CONTROL. "
  
  
  # Caf CPU Boost
  if [[ -d "/sys/module/cpu_boost" ]]; then
  	write "/sys/module/cpu_boost/parameters/input_boost_freq" "0:$cpumxfreq 1:$cpumxfreq 2:$cpumxfreq 3:$cpumxfreq 4:$cpumxfreq 5:$cpumxfreq 6:$cpumxfreq 7:$cpumxfreq"
  	write "/sys/module/cpu_boost/parameters/input_boost_ms" "128"
  	
  	writeLog "[*] TWEAKED CAF INPUT BOOST "
  	
  # CPU input boost
  elif [[ -d "/sys/module/cpu_input_boost" ]]; then
  	write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "128"
  	write "/sys/module/cpu_input_boost/parameters/input_boost_freq_hp" "$cpumxfreq"
  	write "/sys/module/cpu_input_boost/parameters/input_boost_freq_lp" "$cpumxfreq"
  	
  	writeLog "[*] TWEAKED CPU INPUT BOOST"
  	
  fi
  
  # I/O Scheduler Tweaks.
  for queue in /sys/block/*/queue/
  do
  	write "${queue}add_random" 0
  	write "${queue}iostats" 0
  	write "${queue}read_ahead_kb" 512
  	write "${queue}nomerges" 2
  	write "${queue}rq_affinity" 2
  	write "${queue}nr_requests" 256
  done
  
  
  writeLog "[*] TWEAKED I/O SCHEDULER."
  
  
  # CPU Tweaks
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
  do
  	avail_govs=$(cat "${cpu}scaling_available_governors")
  	if [[ "$avail_govs" == *"schedutil"* ]]; then
  		write "${cpu}scaling_governor" schedutil
  		write "${cpu}schedutil/up_rate_limit_us" "500"
  		write "${cpu}schedutil/down_rate_limit_us" "20000"
  		write "${cpu}schedutil/pl" "1"
  		write "${cpu}schedutil/iowait_boost_enable" "1"
  		write "${cpu}schedutil/rate_limit_us" "20000"
  		write "${cpu}schedutil/hispeed_load" "80"
  		write "${cpu}schedutil/hispeed_freq" "$UINT_MAX"
  	elif [[ "$avail_govs" == *"interactive"* ]]; then
  		write "${cpu}scaling_governor" interactive
  		write "${cpu}interactive/timer_rate" "20000"
  		write "${cpu}interactive/boost" "1"
  		write "${cpu}interactive/timer_slack" "20000"
  		write "${cpu}interactive/use_migration_notif" "1"
  		write "${cpu}interactive/ignore_hispeed_on_notif" "1"
  		write "${cpu}interactive/use_sched_load" "1"
  		write "${cpu}interactive/boostpulse" "0"
  		write "${cpu}interactive/fastlane" "1"
  		write "${cpu}interactive/fast_ramp_down" "0"
  		write "${cpu}interactive/sampling_rate" "20000"
  		write "${cpu}interactive/sampling_rate_min" "20000"
  		write "${cpu}interactive/min_sample_time" "20000"
  		write "${cpu}interactive/go_hispeed_load" "80"
  		write "${cpu}interactive/hispeed_freq" "$UINT_MAX"
  	fi
  done
  
  for cpu in /sys/devices/system/cpu/cpu*
  do
  	write "$cpu/online" "1"
  done
  
  
  writeLog "[* ]TWEAKED CPU "
  
  
  # GPU Tweaks.
  write "$gpu/throttling" "0"
  write "$gpu/thermal_pwrlevel" "0"
  write "$gpu/devfreq/adrenoboost" "2"
  write "$gpu/force_no_nap" "1"
  write "$gpu/bus_split" "0"
  write "$gpu/devfreq/max_freq" $(cat "$gpu"/max_gpuclk)
  write "$gpu/devfreq/min_freq" "$gpumx"
  write "$gpu/default_pwrlevel" $(cat "$gpu"/max_pwrlevel)
  write "$gpu/force_bus_on" "1"
  write "$gpu/force_clk_on" "1"
  write "$gpu/force_rail_on" "1"
  write "$gpu/idle_timer" "1050"
  
  if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]]; then
  	write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
  fi
  
  # Enable dvfs
  if [[ -e "/proc/mali/dvfs_enable" ]]; then
  	write "/proc/mali/dvfs_enable" "1"
  fi
  
  if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]]; then
  	write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
  fi
  
  if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
  	write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
  fi
  
  
  writeLog "[*] TWEAKED GPU "
  
  
  # Disable adreno idler
  if [[ -d "/sys/module/adreno_idler" ]]; then
  	write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
  	
  	writeLog "[*] DISABLED ADRENO IDLER."
  	
  fi
  
  # Schedtune Tweaks
  if [[ -d "/dev/stune/" ]]; then
  	write "/dev/stune/background/schedtune.boost" "0"write "/dev/stune/background/schedtune.prefer_idle" "0"
  	write "/dev/stune/foreground/schedtune.boost" "50"
  	write "/dev/stune/foreground/schedtune.prefer_idle" "0"
  	write "/dev/stune/rt/schedtune.boost" "0"
  	write "/dev/stune/rt/schedtune.prefer_idle" "0"
  	write "/dev/stune/top-app/schedtune.boost" "50"
  	write "/dev/stune/top-app/schedtune.prefer_idle" "0"
  	write "/dev/stune/schedtune.boost" "0"
  	write "/dev/stune/schedtune.prefer_idle" "0"
  	
  	writeLog "[*] APPLIED SCHEDTUNE TWEAKS "
  	
  fi
  
  # FS Tweaks.
  if [[ -d "/proc/sys/fs" ]]; then
  	write "/proc/sys/fs/dir-notify-enable" "0"
  	write "/proc/sys/fs/lease-break-time" "20"
  	write "/proc/sys/fs/leases-enable" "1"
  	
  	writeLog "[*] APPLIED FS TWEAKS "
  	
  fi
  
  # Enable dynamic_fsync.
  if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
  	write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
  	
  	writeLog "[*] ENABLED DYNAMIC FSYNC."
  	
  fi
  
  # Scheduler features.
  if [[ -e "/sys/kernel/debug/sched_features" ]]; then
  	write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
  	write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
  	write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
  	write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
  	
  	writeLog "[*] APPLIED SCHEDULER FEATURES "
  	
  fi
  
  # OP Tweaks
  if [[ -d "/sys/module/opchain" ]]; then
  	write "/sys/module/opchain/parameters/chain_on" "0"
  	
  	writeLog "[*] DISABLED ONEPLUS CHAIN "
  	
  fi
  
  # Tweak some kernel settings to improve overall performance.
  write "/proc/sys/kernel/sched_child_runs_first_nosys" "0"
  write "/proc/sys/kernel/sched_child_runs_first" "0"
  write "/proc/sys/kernel/sched_boost" "1"
  write "/proc/sys/kernel/perf_cpu_time_max_percent" "25"
  write "/proc/sys/kernel/sched_autogroup_enabled" "1"
  write "/proc/sys/kernel/random/read_wakeup_threshold" "128"
  write "/proc/sys/kernel/random/write_wakeup_threshold" "1024"
  write "/proc/sys/kernel/random/urandom_min_reseed_secs" "90"
  write "/proc/sys/kernel/sched_tunable_scaling" "0"
  write "/proc/sys/kernel/sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
  write "/proc/sys/kernel/sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
  write "/proc/sys/kernel/sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
  write "/proc/sys/kernel/sched_migration_cost_ns" "5000000"
  write "/proc/sys/kernel/sched_min_task_util_for_colocation" "0"
  write "/proc/sys/kernel/sched_nr_migrate" "128"
  write "/proc/sys/kernel/sched_schedstats" "0"
  write "/proc/sys/kernel/sched_sync_hint_enable" "0"
  write "/proc/sys/kernel/sched_user_hint" "0"
  write "/proc/sys/kernel/sched_conservative_pl" "0"
  write "/proc/sys/kernel/printk_devkmsg" "off"
  
  
  writeLog "[*] TWEAKED KERNEL SETTINGS "
  
  
  # Enable fingerprint boost.
  if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
  	write "/sys/kernel/fp_boost/enabled" "1"
  	
  	writeLog "[*] ENABLED FINGERPRINT BOOST "
  	
  fi
  
  # Set max clocks in gaming / performance profile.
  for minclk in /sys/devices/system/cpu/cpufreq/policy*/
  do
  	if [[ -e "${minclk}scaling_min_freq" ]]; then
  		write "${minclk}scaling_min_freq" "$cpumxfreq"
  		write "${minclk}scaling_max_freq" "$cpumxfreq"
  	fi
  done
  
  for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
  do
  	if [[ -e "${mnclk}scaling_min_freq" ]]
  	then
  		write "${mnclk}scaling_min_freq" "$cpumxfreq"
  		write "${mnclk}scaling_max_freq" "$cpumxfreq"
  	fi
  done
  
  
  writeLog "[*] SET MIN AND MAX CPU CLOCKS "
  
  
  if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
  	write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
  	
  	writeLog "[*] NOT ALLOWED CPUIDLE TO USE DEEPEST STATE. "
  	
  fi
  
  # Enable krait voltage boost
  if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
  	write "/sys/module/acpuclock_krait/parameters/boost" "Y"
  	
  	writeLog "[*] ENABLED KRAIT VOLTAGE BOOST "
  	
  fi
  
  sync
  
  # VM settings to improve overall user experience and performance.
  write "/proc/sys/vm/drop_caches" "3"
  write "/proc/sys/vm/dirty_background_ratio" "5"
  write "/proc/sys/vm/dirty_ratio" "20"
  write "/proc/sys/vm/dirty_expire_centisecs" "500"
  write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
  write "/proc/sys/vm/page-cluster" "0"
  write "/proc/sys/vm/stat_interval" "60"
  write "/proc/sys/vm/swappiness" "100"
  write "/proc/sys/vm/laptop_mode" "0"
  write "/proc/sys/vm/vfs_cache_pressure" "200"
  
  
  writeLog "[*] APPLIED VM TWEAKS."
  
  
  # MSM thermal tweaks
  if [[ -d "/sys/module/msm_thermal" ]]; then
  	write /sys/module/msm_thermal/vdd_restriction/enabled "0"
  	write /sys/module/msm_thermal/core_control/enabled "0"
  	write /sys/module/msm_thermal/parameters/enabled "N"
  	
  	writeLog "[*] APPLIED THERMAL TWEAKS "
  	
  fi
  
  # Disable power efficient workqueue.
  if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
  	write "/sys/module/workqueue/parameters/power_efficient" "N" 
  	
  	writeLog "[*] DISABLED POWER EFFICIENT WORKQUEUE. "
  	
  fi
  
  if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
  	write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
  	
  	writeLog "[*] DISABLED MULTICORE POWER SAVINGS "
  	
  fi
  
  # Fix DT2W.
  if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]; then
  	write "/sys/touchpanel/double_tap" "1"
  	write "/proc/tp_gesture" "1"
  	
  	writeLog "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
  	
  elif [[ -e "/proc/tp_gesture" ]]; then
  	write "/proc/tp_gesture" "1"
  	
  	writeLog "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
  	
  elif [[ -e "/sys/touchpanel/double_tap" ]]; then
  	write "/sys/touchpanel/double_tap" "1"
  	
  	writeLog "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
  	
  fi
  
  # Enable touch boost on gaming and performance profile.
  if [[ -e /sys/module/msm_performance/parameters/touchboost ]]; then
  	write "/sys/module/msm_performance/parameters/touchboost" "1"
  	
  	writeLog "[*] ENABLED TOUCH BOOST "
  	
  elif [[ -e /sys/power/pnpmgr/touch_boost ]]; then
  	write "/sys/power/pnpmgr/touch_boost" "1"
  	
  	writeLog "[*] ENABLED TOUCH BOOST "
  	
  fi
  
  
  # Disable battery saver
  if [[ -d "/sys/module/battery_saver" ]]; then
  	write "/sys/module/battery_saver/parameters/enabled" "N"
  	
  	writeLog "[*] DISABLED BATTERY SAVER "
  	
  fi
  
  # Enable KSM
  if [[ -e "/sys/kernel/mm/ksm/run" ]]; then
  	write "/sys/kernel/mm/ksm/run" "1"
  	
  	writeLog "[*] ENABLED KSM."
  	
  # Enable UKSM
  elif [[ -e "/sys/kernel/mm/uksm/run" ]]; then
  	write "/sys/kernel/mm/uksm/run" "1"
  	
  	writeLog "[*] ENABLED UKSM."
  	
  fi
  
  # Disable arch power
  if [[ -e "/sys/kernel/sched/arch_power" ]]; then
  	write "/sys/kernel/sched/arch_power" "0"
  	
  	writeLog "[*] DISABLED ARCH POWER "
  	
  fi
  
  if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
  	write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
  	
  	writeLog "[*] DISABLED PM2 IDLE SLEEP MODE "
  	
  fi
  
  if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
  	write "/sys/class/lcd/panel/power_reduce" "0"
  	
  	writeLog "[*] DISABLED LCD POWER REDUCE. "
  	
  fi
  
  if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]; then
  	write "/sys/kernel/sched/gentle_fair_sleepers" "0"
  	
  	writeLog "[*] DISABLED GENTLE FAIR SLEEPERS. "
  	
  fi

writeLog " "
writeLog "[ Thanks For All ]"