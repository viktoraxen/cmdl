# frozen_string_literal: true

require_relative 'test'
require_relative '../src/core/log/log'

$stdout = File.new('/dev/null', 'w')

Log.initialize(Logger::DEBUG, $stdout)

tests_dir = File.join(File.dirname(__FILE__), 'run')

tot_parsed = 0
tot_evaluated = 0
tot_synthesized = 0
tot_simulated = 0

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
    test_file.run_tests

    tot_skipped += test_file.skipped
    tot_warnings += test_file.warnings
    tot_passed += test_file.passed
    tot_failed += test_file.failed
    tot_ran += test_file.total

    tot_parsed += test_file.parsed
    tot_evaluated += test_file.evaluated
    tot_synthesized += test_file.synthesized
    tot_simulated += test_file.simulated

    tot_time += test_file.total_time

    STDOUT.puts
end

$stdout = STDOUT

skip_str = tot_skipped.to_s.center(3).gray
warning_str = tot_warnings.to_s.center(3).yellow
failed_str = tot_failed.to_s.center(3).red
passed_str = tot_passed.to_s.center(3).green
total_str  = tot_ran.to_s.center(3)

result_str = [skip_str, warning_str, failed_str, passed_str, total_str].join(' / ')

puts "Total time: #{tot_time.round(2)} ms"
puts "Result: #{result_str}"

started = TestFile.stop_stage_symbols[0].center(5)
parsed = TestFile.stop_stage_symbols[1].center(5).red
evaluated = TestFile.stop_stage_symbols[2].center(5).yellow
synthesized = TestFile.stop_stage_symbols[3].center(5).blue
simulated = TestFile.stop_stage_symbols[4].center(5).green

total_str = tot_ran.to_s.center(5)
parsed_str = tot_parsed.to_s.center(5).red
evaluated_str = tot_evaluated.to_s.center(5).yellow
synthesized_str = tot_synthesized.to_s.center(5).blue
simulated_str = tot_simulated.to_s.center(5).green

puts '------------------------------------'

puts 'Stages: ' + [started, parsed, evaluated, synthesized, simulated].join(' | ')
puts '        ' + [total_str, parsed_str, evaluated_str, synthesized_str, simulated_str].join(' | ')

puts 'All attempted tests passed!'.green if tot_passed == tot_ran - tot_skipped - tot_warnings
