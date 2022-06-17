# 監視ログファイルのチェックプログラム
# Q2. N回以上連続してタイムアウトした場合、故障とみなす。
#     故障状態のサーバアドレスとそのサーバの故障期間を出力する

# ログデータの読み込み(共通部分)
log_data = Array.new(2)
log_counter = 0
i = 0

File.open('log.txt', 'r') do |f|
  f.each_line do |file|
    log_data[i] = file.split(',')
    # ログの改行/nを取り除いて、保存し直す
    log_data[i][2] = log_data[i][2].chomp
    i += 1
    log_counter = i
  end
end

# タイムアウトの閾値Nを入力する
puts "故障とみなすタイムアウトの連続回数を入力してください"
num = gets.chomp.to_i

check_log = []
check_num = 0
check_i = 0
i = 0

# 故障状態を検知する
# 1) 格納したログデータ文だけ、ループを回す
# 2) 故障状態を検知したら、check_logに格納する
# 3) 2)で故障状態を検知した場合、故障がN回連続するか検証する
# 4) もし故障がN回連続したら、「故障状態」と判断し、確認日時の差分を算出する。これを故障期間とする
log_counter.times do
  check_num = 0
  # 1回目の異常検知
  if log_data[i][2] == '-'
    check_log = log_data[i]
    check_num += 1
    check_i = i
    # 1回目以降の応答時間を検証
    for l in log_data[check_i .. log_counter]
      if l[2] == '-' && l[1] == check_log[1]
        log = l
        check_num += 1
      else
        check_log = log_data[i]
        break
      end
    end
  end
  # 異常がN回以上連続したか判定
  # N回以上なら故障と判断し、故障期間を表示
  if check_num >= num
    error_period = log[0].to_f-check_log[0].to_f
    puts "#####故障検知#####"
    puts "故障箇所のアドレス:#{log[1]}, 故障期間:#{error_period}s"
    break
  end
  i += 1
end
