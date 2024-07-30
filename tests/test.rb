# frozen_string_literal: true

require 'colorize'

require_relative '../src/core/cmdl_run'

class TestFile
    attr_reader :total_time, :parsed, :evaluated, :synthesized, :simulated, :skipped, :warnings, :passed, :failed, :total

    def TestFile.stop_stage_symbols
        {
            0 => '',
            1 => '󰹩',
            2 => '',
            3 => '',
            4 => ''
        }
    end

    def initialize(filepath, tests_dir = File.join(File.dirname(__FILE__), 'run'))
        @section_pattern = /<<\s+(.*?)\n((?:<.*?\n)*)(.*?)(?=<<\s|\z)/m
        @indent = ' ' * 4
        @colors = {
            skipped: :gray,
            failure: :red,
            success: :green,
            warning: :yellow
        }
        @symbols = {
            skipped:  '',
            threw:    '',
            finished: '',
            warning:  ''
        }

        file_content = File.read(File.join(tests_dir, filepath))
        sections = file_content.scan(@section_pattern)

        @title = filepath.split('.')[...-1].join('.').capitalize

        @tests = sections.map do |name, tags, content|
            Test.new(name, tags, content)
        end

        @skipped  = 0
        @warnings = 0
        @passed   = 0
        @failed   = 0
        @total    = @tests.length

        @parsed      = 0
        @evaluated   = 0
        @synthesized = 0
        @simulated   = 0

        @total_time = 0
    end

    def run_tests
        _std_puts "Running test file #{@title}"

        @tests.each do |test|
            result, symbol, exception = test.run

            @total_time += test.elapsed_time unless test.elapsed_time.nil?

            color = @colors[result]
            symbol = @symbols[symbol]
            stop_stage = TestFile.stop_stage_symbols[test.reached_stage]

            result_str = "#{symbol} #{stop_stage} : #{test.name}".colorize(color)
            unless exception.nil?
                result_str += " - #{exception.class}" if exception.is_a? StandardError
                exception_location = exception.backtrace.first.match(%r{/(?<loc>.*:\d*)})[:loc].split('/').last if exception.is_a? StandardError
                result_str += " - #{exception_location}" unless exception_location.nil?
                result_str += " - #{exception.to_s.strip}"
            end

            _std_puts "#{@indent}#{result_str}"

            @skipped  += 1 if result == :skipped
            @warnings += 1 if result == :warning
            @passed   += 1 if result == :success
            @failed   += 1 if result == :failure

            @parsed      += 1 if test.reached_stage > 0
            @evaluated   += 1 if test.reached_stage > 1
            @synthesized += 1 if test.reached_stage > 2
            @simulated   += 1 if test.reached_stage > 3
        end

        _print_results
    end

    def _print_results
        skip_str = @skipped.to_s.gray
        warning_str = @warnings.to_s.yellow
        failed_str = @failed.to_s.red
        passed_str = @passed.to_s.green
        total_str  = @total.to_s

        result_str = [skip_str, warning_str, failed_str, passed_str, total_str].join(' / ')

        _std_puts "#{@indent}Elapsed time: #{@total_time.round(2)} ms"
        _std_puts "#{@indent}#{result_str}"
    end

    def _std_puts(str)
        STDOUT.puts str
    end
end

class Test
    attr_reader :name, :should_finish, :skip, :elapsed_time, :reached_stage

    def initialize(name, tags, content, parser = CmdlParser.new(Logger::ERROR))
        @name    = name
        @tags    = tags
        @content = content
        @parser  = parser

        params = get_params(tags)

        @should_finish    = params[:should_finish]
        @valid_exceptions = params[:valid_exceptions]
        @skip             = params[:skip]
        @stop_stage       = params[:stop_stage]
        @evaluations      = params[:evaluations]

        @tree       = nil
        @root_scope = nil
        @network    = nil

        @elapsed_time = nil

        @reached_stage = 0
    end

    def run
        return :skipped, :skipped if @skip
        return :warning, :warning, 'Test content empty' if @content.strip.empty?

        t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        begin
            parse
            evaluate   unless @stop_stage < 2
            synthesize unless @stop_stage < 3
            validate   unless @stop_stage < 4
        rescue *@valid_exceptions
            result = :success, :threw
        rescue StandardError => e
            result = :failure, :threw, e
        else
            result = :failure, :finished
            result = :success, :finished if @should_finish
        ensure
            t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            @elapsed_time = (t1 - t0) * 1000
        end

        result
    end

    def parse
        @tree = @parser.parse(@content)
        @reached_stage = 1
    end

    def evaluate
        @root_scope = @tree.evaluate
        @reached_stage = 2
    end

    def synthesize
        @network = @root_scope.synthesize
        @reached_stage = 3
    end

    def validate
        results = @network.state
        interface = Interface.new(@network)

        @evaluations.each do |type, (name, value)|
            if type == :validation && results[name] != value
                raise ValidationResultError,
                      "Expected #{name} to be #{value}, but it was #{results[name]}"
            elsif type == :action
                interface.change(name, value.to_i)
                results = @network.state
            end
        end

        @reached_stage = 4
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

    def get_params(tags)
        params = {
            should_finish:    true,
            valid_exceptions: [],
            skip:             false,
            stop_stage:       4,
            results:          {}
        }

        return params if tags.nil?

        tags = tags.lines.map(&:strip).select { |line| line.start_with?('<') }.map { |line| line[1..].strip }

        params[:skip] = tags.include? 'skip'
        return params if params[:skip]

        stop_stage_map = {
            'parse'      => 1,
            'evaluate'   => 2,
            'synthesize' => 3,
            'validate'   => 4
        }

        params[:evaluations] = []

        tags.each do |tag|
            if tag =~ /^until.*$/
                stop_stage = tag.scan(/until\s*:\s*([A-Za-z0-9_]+)/)&.flatten&.first

                params[:stop_stage] = stop_stage_map[stop_stage]
            elsif tag =~ /^fail.*$/
                params[:should_finish] = true
                params[:valid_exceptions] = _get_valid_exceptions(tag)
            else
                params[:evaluations].append evaluation(tag)
                # STDOUT.puts tag
            end
        end

        params[:evaluations] = params[:evaluations]
        # params[:evaluations].each { |e| STDOUT.puts e.join(' : ') }

        # stop_tag = tags.find { |tag| tag =~ /^until.*$/ }
        # stop_stage = stop_tag&.scan(/until\s*:\s*([A-Za-z0-9_]+)/)&.flatten&.first
        #
        #
        # fail_tag = tags.find { |tag| tag =~ /^fail.*$/ }

        # unless params[:should_finish]

        # params[:expected_results] = tags.map do |tag|
        # end

        params
    end

    def evaluation(tag)
        validation_match = tag.strip.match(/^(?<name>\w+)\s*:\s*(?<value>b[x01]+|\d+)\s*:?\s*(?<width>\d+)?$/)
        action_match = tag.strip.match(/^(?<name>\w+)\s*<=\s*(?<value>b[x01]+|\d+)\s*$/)

        return validation(validation_match) unless validation_match.to_s == ''
        return action(action_match) unless action_match.to_s == ''

        nil
    end

    def validation(match)
        name, value, width = match.captures

        value = evaluate_value(value, width)

        [:validation, [name, value]]
    end

    def action(match)
        [:action, match.captures]
    end

    def evaluate_value(value, width)
        return value[1..] if value[0] == 'b'

        value.to_i.to_s(2).rjust(width.to_i, '0')
    end
end
