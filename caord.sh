file_name=xx
log=xx_log
rsync_output=xxx
io_output=xxxx
rsync_transferred_file_size=xxxxx
util_output=xxxxxx
file_size=$(du $file_name | cut -f 1)   
bw_max=116060.16                        
bw_disuse=7741.21                       
bw_max_limit=$(echo "scale=2; $bw_max - $bw_disuse" | bc)
bw_1_per=$(echo "scale=2; $bw_max/100" | bc)  
limit_time=28800                               
bw_limit_f=$(echo "scale=2; $file_size / $limit_time" | bc)  
bw_limit_b=$bw_limit_f                                      
ws_rate=11.37

date "+%Y-%m-%d %H:%M:%S" > $log

# rsyncコマンドの実行
rsync -avhP --append --bwlimit=$bw_limit_f ~/$file_name 〇〇@123.456.789.012:~/ > $rsync_output &
# rsyncコマンドのプロセスIDを取得
rsync_pid=$(ps -o pgid= -p $!)

# iostatコマンドの実行
iostat -x -t 1 sda > $io_output &
# iostatコマンドのプロセスIDを取得
iostat_pid=$(ps -o pgid= -p $!)

sleep 3

# 開始時刻を記録
start_time=$(date +%s.%N)

while true; do
    # ファイルサイズ取得
    $(python3 file_size.py)
    transfer_size=$(tail -1 $rsync_transferred_file_size)
    left_size=$(echo "scale=2; $file_size - $transfer_size" | bc)
    echo -n "残りファイルサイズ:"$left_size"KB: " >> $log

    # 帯域幅取得
    $(python3 util_extraction.py)
    util=$(tail -1 $util_output | cut -f 1 -d " ")
    echo -n "合計帯域幅使用率:"$util"%: " >> $log

    ws=$(tail -1 $util_output | cut -f 2 -d " ")
    util_w=$(echo "scale=2; $ws / $ws_rate" | bc)
    echo -n "書き込み帯域幅使用率:"$util_w"%: " >> $log

    # 使用可能な帯域幅の計算
    bw_available=$(echo "scale=2; $bw_max_limit - $util_w * $bw_1_per" | bc)
    bw_limit=$bw_available

    # 制限する帯域幅の上限下限設定
    if [ "$(echo "$bw_limit <= $bw_limit_f" | bc)" == 1 ]; then
        bw_limit=$bw_limit_f
        # echo "これ以上帯域幅は下げられません" >> $log
    elif [ "$(echo "$bw_limit >= $bw_max_limit" | bc)" == 1 ]; then
        bw_limit=$bw_max_limit
        # echo "これ以上帯域幅は上げられません" >> $log
    fi

    echo -n "制限する帯域幅:"$bw_limit": " >> $log

    # 制限する帯域幅が前の値と同じでないならrsyncを中断、再開
    if [ "$(echo "$bw_limit != $bw_limit_b" | bc)" == 1 ]; then
        echo -n "rsyncを中断、再開します" >> $log
        kill -TERM $rsync_pid > /dev/null 2>&1
        rsync -avhP --append --bwlimit=$bw_limit ~/$file_name 〇〇@123.456.789.012:~/ >> $rsync_output &
        rsync_pid=$(ps -o pgid= -p $!)
    fi

    if [ "$(echo "$left_size <= 0" | bc)" == 1 ]; then
        # 終了時刻を記録
        end_time=$(date +%s.%N)
        # 実行時間を計算
        execution_time=$(echo "$end_time - $start_time" | bc)
        echo "バックアップが完了しました" >> $log
        # 結果を出力
        echo $execution_time >> /home/ida/4th/$log
        kill -TERM $rsync_pid
        kill -TERM $iostat_pid
        break
    fi

    # 制限する帯域幅の保存
    bw_limit_b=$bw_limit

    echo -e "\n" >> $log
    date "+%Y-%m-%d %H:%M:%S" >> $log
    sleep 1
done
