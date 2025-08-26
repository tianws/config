#!/bin/bash

# -----------------------------------------------------------------------------
# 脚本名称: mouse_mover_random_xy.sh
# 功能描述: 每隔随机时间平滑移动鼠标，并在指定时间段、周末和节假日禁用，
#          在水平和垂直方向上随机移动。
#          从配置文件中读取禁用时间和日期信息
# -----------------------------------------------------------------------------

# 设置配置文件路径
config_file="config.ini"

# -----------------------------------------------------------------------------
# 函数定义
# -----------------------------------------------------------------------------

# 从配置文件读取禁用时间段
read_disabled_time_periods() {
  readarray -t disabled_start_times < <(grep "^disabled_start_time_" "$config_file" | cut -d "=" -f2)
  readarray -t disabled_end_times < <(grep "^disabled_end_time_" "$config_file" | cut -d "=" -f2)
}

# 从配置文件读取节假日列表
read_holidays() {
  holidays=$(grep "^holidays" "$config_file" | cut -d "=" -f2 | tr ',' '\n')
}

# 从配置文件读取是否禁用周末
read_disable_weekends() {
   disable_weekends=$(grep "^disable_weekends" "$config_file" | cut -d "=" -f2)
}

# 检测当前时间是否在禁用时间段内
is_disabled_time() {
    local current_time=$1
    local is_disabled=false

    for i in "${!disabled_start_times[@]}"; do
        local start_time="${disabled_start_times[$i]}"
        local end_time="${disabled_end_times[$i]}"

        if [[ "$current_time" -ge "$start_time" ]] && [[ "$current_time" -lt "$end_time" ]]; then
            is_disabled=true
            break
        fi
    done

    echo "$is_disabled"
}

# 检测当前日期是否为节假日
is_holiday() {
    local current_date=$1
    local is_holiday_result=false

    for holiday in $holidays; do
        if [[ "$current_date" == "$holiday" ]]; then
            is_holiday_result=true
            break
        fi
    done

    echo "$is_holiday_result"
}

# 检测当前日期是否为周末
is_weekend() {
    local current_weekday=$1
    local disable_weekends_result=$2
    local is_weekend_result=false

    if [[ "$disable_weekends_result" == "true" ]]; then
        if [[ "$current_weekday" -eq 0 ]] || [[ "$current_weekday" -eq 6 ]]; then
           is_weekend_result=true
        fi
    fi
     echo "$is_weekend_result"
}

# 生成随机的移动像素值
generate_random_move() {
    local random_move_x=$((RANDOM % 6 + 5))  # 5 to 10
    local random_move_y=$((RANDOM % 6 + 5))  # 5 to 10

    # 生成随机方向， 一半向左移动，一半向右移动
    local random_direction_x=$((RANDOM % 2))
    if [[ "$random_direction_x" -eq 0 ]]; then
        random_move_x=$((random_move_x * -1))  #向左移动
    fi
    #生成随机纵向方向， 一半向上移动，一半向下移动
    local random_direction_y=$((RANDOM % 2))
    if [[ "$random_direction_y" -eq 0 ]]; then
        random_move_y=$((random_move_y * -1))  #向下移动
    fi

    echo "$random_move_x $random_move_y"
}

# 平滑移动鼠标
move_mouse_smooth() {
    local start_x=$1
    local start_y=$2
    local end_x=$3
    local end_y=$4
    local steps=10 # 分成10个步骤移动

    local dx=$((end_x - start_x))
    local dy=$((end_y - start_y))

    for ((i=1; i<=steps; i++)); do
      # 计算当前步骤的目标位置
      local current_x=$((start_x + (dx * i / steps)))
      local current_y=$((start_y + (dy * i / steps)))

      # 使用 xdotool 移动鼠标
       xdotool mousemove "$current_x" "$current_y"
       # 添加随机的延迟时间
       local random_delay=$((RANDOM % 50 + 10)) #10-60毫秒
       sleep "$(echo "scale=3; $random_delay / 1000" | bc)"
    done
}

# 生成随机等待时间
generate_random_sleep_time() {
    local random_sleep=$((RANDOM % 16 + 5))
    echo "$random_sleep"
}

# -----------------------------------------------------------------------------
# 主循环
# -----------------------------------------------------------------------------

# 读取配置
read_disabled_time_periods
read_holidays
read_disable_weekends

while true
do
  # 获取当前时间
  current_time=$(date +%H)

  # 获取当前日期（YYYY-MM-DD 格式）
  current_date=$(date +%Y-%m-%d)

  # 获取当前星期几 (0-6, 0为周日， 6为周六)
  current_weekday=$(date +%w)

  # 检测是否禁用
  if [[ "$(is_disabled_time "$current_time")" == "true" ]] || [[ "$(is_weekend "$current_weekday" "$disable_weekends")" == "true" ]] || [[ "$(is_holiday "$current_date")" == "true" ]]; then
    echo "禁用时间段，周末或节假日，不移动鼠标"
    sleep 60  # 每隔 60 秒检测一次时间
  else

    # 获取当前鼠标位置
    mouse_x=$(xdotool getmouselocation | grep -oP 'x:(\d+)' | grep -oP '\d+')
    mouse_y=$(xdotool getmouselocation | grep -oP 'y:(\d+)' | grep -oP '\d+')


    # 生成随机的移动像素值
    read random_move_x random_move_y < <(generate_random_move)


    # 计算新的鼠标位置
    new_x=$((mouse_x + random_move_x))
    new_y=$((mouse_y + random_move_y))


     # 获取屏幕宽度
    screen_width=$(xrandr | grep '*' | awk '{print $1}' | cut -d 'x' -f1 | head -n 1)
    if [ -z "$screen_width" ]; then
         echo "Error: Could not determine screen width"
         continue  # 如果获取屏幕宽度失败，则跳过本次循环
    fi

    # 如果鼠标移动到屏幕边缘，则反向移动
    if [[ "$new_x" =~ ^-?[0-9]+$ ]] && [[ "${screen_width}" =~ ^[0-9]+$ ]]; then
       if [[ "$new_x" -gt "$screen_width" ]]; then
           new_x=$((mouse_x - random_move_x))
       fi
    else
         echo "Error: new_x or screen_width is not an integer"
          continue # 如果类型检测失败，则跳过本次循环
    fi

     # 平滑移动鼠标
    move_mouse_smooth "$mouse_x" "$mouse_y" "$new_x" "$new_y"

    # 生成随机等待时间
    random_sleep=$(generate_random_sleep_time)
    # 等待随机的时间
    sleep "$random_sleep"
  fi
done
