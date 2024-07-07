# frozen_string_literal: true

require 'colorize'

require_relative '../src/core/run_language'

class TestFile
    @@section_pattern = /<<\s+(.*?)\n((?:<.*?\n)*)(.*?)(?=<<\s|\z)/m
    @@indent = ' ' * 4
    @@colors = {
        skipped: :gray,
        failure: :red,
        success: :green,
        warning: :yellow
    }
    @@symbols = {
        skipped:  '',
        threw:    '',
        finished: '',
        warning:  ''
    }
    @@stop_stage_symbols = {
        1 => '󰯃',
        2 => '󰹩',
        3 => ''
    }

    attr_reader :total_time

    def initialize(filepath, tests_dir = File.join(File.dirname(__FILE__), 'run'))
        file_content = File.read(File.join(tests_dir, filepath))
        sections = file_content.scan(@@section_pattern)

        @title = filepath.split('.')[...-1].join('.').capitalize

        @tests = sections.map do |name, tags, content|
            Test.new(name, tags, content)
        end

        @skipped_tests = 0
        @warnings      = 0
        @passed_tests  = 0
        @failed_tests  = 0
        @total_tests   = @tests.length

        @total_time = 0
    end

    def run_tests
        _std_puts "Running test file #{@title}"

        @tests.each do |test|
            result, symbol, exception = test.run

            @total_time += test.elapsed_time unless test.elapsed_time.nil?

            color = @@colors[result]
            symbol = @@symbols[symbol]
            stop_stage = @@stop_stage_symbols[test.stop_stage]

            result_str = "#{symbol} #{stop_stage}: #{test.name}".colorize(color)
            result_str += " - #{exception.class}: #{exception.to_s.strip}" unless exception.nil?

            _std_puts "#{@@indent}#{result_str}"

            @skipped_tests += 1 if result == :skipped
            @warnings      += 1 if result == :warning
            @passed_tests  += 1 if result == :success
            @failed_tests  += 1 if result == :failure
        end

        _print_results

        return @skipped_tests, @warnings, @passed_tests, @failed_tests, @total_tests
    end

    def _print_results
        skip_str   = @skipped_tests.to_s.gray
        warning_str = @warnings.to_s.yellow
        failed_str = @failed_tests.to_s.red
        passed_str = @passed_tests.to_s.green
        total_str  = @total_tests.to_s

        result_str = [skip_str, warning_str, failed_str, passed_str, total_str].join(' / ')

        _std_puts "#{@@indent}Elapsed time: #{@total_time.round(2)} ms"
        _std_puts "#{@@indent}#{result_str}"
    end

    def _std_puts(str)
        STDOUT.puts str
    end
end

class Test
    attr_reader :name, :should_finish, :skip, :elapsed_time, :stop_stage

    def initialize(name, tags, content, parser = CmdlParser.new(Logger::ERROR))
        @name    = name
        @tags    = tags
        @content = content
        @parser  = parser

        params = _get_params(tags)

        @should_finish    = params[:should_finish]
        @valid_exceptions = params[:valid_exceptions]
        @skip             = params[:skip]
        @stop_stage       = params[:stop_stage]

        @tree       = nil
        @root_scope = nil
        @network    = nil

        @elapsed_time = nil
    end

    def run
        return :skipped, :skipped if @skip
        return :warning, :warning, "Test content empty" if @content.strip.empty?

        t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        begin
            parse
            evaluate unless @stop_stage < 2
            synthesize unless @stop_stage < 3
        rescue *@valid_exceptions
            result = :success, :threw
        rescue => e
            result = :failure, :threw, e
        else 
            result = :failure, :finished
            result = :success, :finished if @should_finish
        ensure
            t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            @elapsed_time = (t1 - t0) * 1000
        end

        return result
    end

    def parse
        @tree = @parser.parse(@content)
    end

    def evaluate
        @root_scope = @tree.evaluate
    end

    def synthesize
        @network = @root_scope.synthesize
    end

    def content_empty
        @content.strip.empty?
    end

    def _get_valid_exceptions(fail_tag)
        return [] if fail_tag.nil?

        fail_tag.scan(/fail\s*:\s*([A-Za-z0-9_,\s]+)/).flatten.join(',').split(',').map do |exception|
            Object.const_get(exception.strip)
        end
    end

    def _get_params(tags)
        params = {
            should_finish:    true,
            valid_exceptions: [],
            skip:             false,
            stop_stage:       3
        }

        return params if tags.nil?

        tags = tags.lines.map(&:strip).select { |line| line.start_with?('<') }.map { |line| line[1..].strip }

        params[:skip] = tags.include? 'skip'

        stop_tag = tags.find { |tag| tag =~ /^until.*$/ }
        stop_stage = stop_tag&.scan(/until\s*:\s*([A-Za-z0-9_]+)/)&.flatten&.first

        stop_stage_map = {
            'parse'      => 1,
            'evaluate'   => 2,
            'synthesize' => 3
        }

        params[:stop_stage] = stop_stage_map[stop_stage] unless stop_stage.nil?

        fail_tag = tags.find { |tag| tag =~ /^fail.*$/ }

        params[:should_finish] = fail_tag.nil?

        if !params[:should_finish]
            params[:valid_exceptions] = _get_valid_exceptions(fail_tag)
        end

        params
    end

end
