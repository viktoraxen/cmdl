# frozen_string_literal: true

require_relative 'test'
require_relative '../src/core/log/log'

$stdout = File.new('/dev/null', 'w')

Log.initialize(Logger::DEBUG, $stdout)

tests_dir = File.join(File.dirname(__FILE__), 'run')

tot_skipped = 0
tot_warnings = 0
tot_passed = 0
tot_failed = 0
tot_ran = 0
tot_time = 0

Dir.entries(tests_dir).sort.each do |filename|
    next if File.directory?(File.join(tests_dir, filename))
    next unless filename.end_with?('.cmd')
    next unless ARGV.empty? || ARGV.include?(filename.split('.')[0])

    test_file = TestFile.new(filename)
    skipped, warnings, passed, failed, ran = test_file.run_tests

    tot_skipped += skipped
    tot_warnings += warnings
    tot_passed += passed
    tot_failed += failed
    tot_ran += ran

    tot_time += test_file.total_time

    STDOUT.puts
end

$stdout = STDOUT

skip_str = tot_skipped.to_s.gray
warning_str = tot_warnings.to_s.yellow
failed_str = tot_failed.to_s.red
passed_str = tot_passed.to_s.green
total_str  = tot_ran.to_s

result_str = [skip_str, warning_str, failed_str, passed_str, total_str].join(' / ')

puts "Total time: #{tot_time.round(2)} ms"
puts "Result: #{result_str}"

puts 'All attempted tests passed!'.green if tot_passed == tot_ran - tot_skipped - tot_warnings
