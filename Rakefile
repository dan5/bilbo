Test_script = 'test/test.rb'
Backup_log = 'log/log0.txt'
Test_log = 'log/log.txt'

desc "Run the all specs and tests."
task :default => :diff

desc "diff `Backup_log' <(ruby #{Test_script})"
task :diff do
  sh "ruby #{Test_script} > #{Test_log}"
  begin
    sh "diff #{Backup_log} #{Test_log}"
    puts :ok
  rescue
  end
end

desc "Update `Backup_log' file."
task :update => 'log' do
  rm_rf 'test/boot'
  sh "ruby setup.rb test/boot"
  sh "ruby #{Test_script} > #{Backup_log}"
end

directory 'log'
