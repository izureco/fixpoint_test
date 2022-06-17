# 監視ログファイルのチェックプログラム
# Q3. 直近m回の平均応答時間がtミリ秒を超えた場合、サーバの過負荷状態だと判断する
#     各サーバーの過負荷状態となっている期間を出力する

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

# 検証の回数mと、応答時間tを入力する
puts "1.過負荷状態を検証する回数を入力してください"
count = gets.chomp.to_i
puts "2.過負荷状態とみなす平均応答時間(ms)を入力してください"
m_second = gets.chomp.to_i

check_count = 0
check_period = 0
period_ave = 0
i = 0
j = 0

# 故障状態を検知する
# 1) 格納したログデータ文だけ、ループを回す
# 2) ユーザーから入力された検証回数分だけ、平均応答時間を計算する
# 3) ユーザーから入力された平均応答時間を超えた場合、過負荷状態と判断し、その間の期間と応答時間を出力する
log_counter.times do
  check_count = i
  # もし検証回数を上回ったら、その時点から検証回数分の応答時間を計算する
  if check_count >= count
    check_period = 0
    j = check_count
    count.times do
      check_period += log_data[j][2].to_i
      j -= 1
    end
    period_ave = check_period / count
    # もし、応答時間平均が過負荷状態を超えた場合、期間を出力する
    if period_ave >= m_second
      puts "#####過負荷状態検知#####"
      puts "過負荷状態の期間:#{log_data[j][0]}~#{log_data[j-count][0]}, 平均応答時間:#{period_ave}ミリ秒"
    end
  end
  i += 1
end