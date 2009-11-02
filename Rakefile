Backup_log = 'log/log0.txt'

desc "Run the all specs and tests."
task :default => :diff

desc "diff `Backup_log' <(ruby test/test.rb)"
task :diff do
  sh "ruby test/test.rb > log/log.txt"
  begin
    sh "diff #{Backup_log} log/log.txt"
    puts :ok
  rescue
  end
end

desc "Update `Backup_log' file."
task :update => :log do
  sh "ruby test/test.rb > #{Backup_log}"
end

directory :log
