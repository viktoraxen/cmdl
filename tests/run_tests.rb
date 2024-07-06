# frozen_string_literal: true

require_relative 'test'
require_relative '../src/log/log'

Log.set_log_level(Logger::ERROR)

tests_dir = File.join(File.dirname(__FILE__), 'run')

tot_skipped, tot_warnings, tot_passed, tot_failed, tot_ran = 0, 0, 0, 0, 0

Dir.entries(tests_dir).each do |filename|
    next if File.directory?(File.join(tests_dir, filename))

    test_file = TestFile.new(filename)
    skipped, warnings, passed, failed, ran = test_file.run_tests
    
    tot_skipped += skipped
    tot_warnings += warnings
    tot_passed += passed
    tot_failed += failed
    tot_ran += ran
end

puts

skip_str   = tot_skipped.to_s.gray
warning_str = tot_warnings.to_s.yellow
failed_str = tot_failed.to_s.red
passed_str = tot_passed.to_s.green
total_str  = tot_ran.to_s

result_str = [skip_str, warning_str, failed_str, passed_str, total_str].join(' / ')

puts "Result: #{result_str}"

puts 'All attempted tests passed!'.green if tot_passed == tot_ran - tot_skipped
