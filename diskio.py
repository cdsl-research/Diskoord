import re
import subprocess
import time

bw_f = 0
exec_t = 0.0829632347
input_file_path = "xx"
output_file_path = "xxx"
pattern_bw = r'sda\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+(\d+\.\d+)'
cmd_loc = "ssh -i ~/.ssh/xxxx hoge@hoge:locust -f ~/locustfile.py --headless --csv ~/hogehoge --users 123 --spawn-rate 123 -t 123s &"
cmd_io = "iostat -xt sda 1 > xxxx &"

proc_loc = subprocess.Popen(cmd_loc, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
proc_io = subprocess.Popen(cmd_io, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
time.sleep(123)

# ファイルを読み取りモードで開く
with open(input_file_path, 'r') as input_file:
    # ファイルの内容をテキストとして読み込む
    text = input_file.read()
    
    # 正規表現パターンに一致する部分を検索
    matches_bw = re.findall(pattern_bw, text)
    
    for i in range(len(matches_bw)):
        bw_diff = matches_bw[i+1] - matches_bw[i]
        if bw_diff > bw_f:
            bw_f = bw_diff
    bw = bw_f / exec_t
    # マッチした値を出力ファイルに書き込む
    with open(output_file_path, 'w') as output_file:
        output_file.write(bw)
