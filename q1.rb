# 監視ログファイルのチェックプログラム
# Q1. 故障状態のサーバアドレスとそのサーバの故障期間を出力する

# ログデータの読み込み(共通部分)
log_data = Array.new(2)
i = 0

File.open('log.txt', 'r') do |f|
  f.each_line do |file|
    log_data[i] = file.split(',')
    # ログの改行/nを取り除いて、保存し直す
    log_data[i][2] = log_data[i][2].chomp
    i += 1
  end
end

# 故障状態を検知する
# 1) 格納したログデータを1つずつ参照する
# 2) 故障状態を検知したら、check_logに格納する
# 3) 「故障状態」のIPアドレスと一致したら、確認日時の差分を算出する。これを故障期間とする

check_log = []
log_data.each do |log|
  # 故障状態('-')のlogをチェック用配列に格納
  if log[2] == '-'
    check_log = log
  elsif check_log[1] == log[1] && check_log.any?
    error_period = log[0].to_f-check_log[0].to_f
    puts "#####故障検知#####"
    puts "故障箇所のアドレス:#{check_log[1]}, 故障期間:#{error_period}s"
  end
end
