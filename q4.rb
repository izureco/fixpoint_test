# 監視ログファイルのチェックプログラム
# Q4. サブネット内のサーバがすべて故障している場合は、そのサブネットの故障とみなす

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

# 故障状態を検知する(q3と同じアルゴリズム)
# 1) 格納したログデータ文だけ、ループを回す
# 2) ユーザーから入力された検証回数分だけ、平均応答時間を計算する
# 3) ユーザーから入力された平均応答時間を超えた場合、過負荷状態と判断し、その間の期間と応答時間を出力する
check_log = []
check_num = 0
check_i = 0
i = 0

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

  error_server = 0
  error_period = 0

  # サブネット内のサーバーを探索
  # 1) もし故障状態がN回以上連続した場合、故障と判断し同一サブネット内のサーバーを探索する
  # 2) ネットワークプレフィックスが、1)と一致するか検証する
  # 3) もし一致した場合、同一サブネットと判断し、それぞれのサーバーのIPアドレスと故障期間を表示する

  if check_num >= num
    # サブネット内のサーバーを探索
    check_str = log[1]
    log_data.each do |l|
      # ネットワークプレフィックスが一致なら、同一サブネット内のサーバと判断する
      if check_str.end_with?(l[1][-3,3]) && check_str != l[1]
        error_server = l[1]
        break
      end
    end
    error_period = log[0].to_f-check_log[0].to_f
    puts "#####故障検知#####"
    puts "故障箇所のサーバー:#{check_str},#{error_server} 故障期間:#{error_period}s"
    break
  end
  i += 1
end
