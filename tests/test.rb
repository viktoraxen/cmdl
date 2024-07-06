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
    end

    def run_tests
        puts "Running test file #{@title}"

        @tests.each do |test|
            result, symbol, exception = test.run

            color = @@colors[result]
            symbol = @@symbols[symbol]

            result_str = "#{symbol}: #{test.name}".colorize(color)
            result_str += " - #{exception.to_s.strip}" unless exception.nil?

            puts "#{@@indent}#{result_str}"

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

        puts "#{@@indent}#{result_str}"
    end
end

class Test
    attr_reader :name, :should_finish, :skip

    def initialize(name, tags, content, parser = CmdlParser.new(Logger::ERROR))
        @name    = name
        @tags    = tags
        @content = content
        @parser  = parser

        params = _get_params(tags)

        @should_finish    = params[:should_finish]
        @valid_exceptions = params[:valid_exceptions]
        @skip             = params[:skip]

        @tree       = nil
        @root_scope = nil
        @network    = nil

        @elapsed_time = nil
    end

    def run
        return :skipped, :skipped if @skip
        return :warning, :warning, "Test content empty" if content_empty

        begin
            parse
            evaluate
            # synthesize
        rescue *@valid_exceptions
            return :success, :threw
        rescue => e
            return :failure, :threw, e
        else 
            return :success, :finished if @should_finish
            return :failure, :finished
        end
    end

    def parse
        @tree = @parser.parse(@content)
    end

    def evaluate
        @root_scope = @tree.evaluate
    end

    def synthesize
        @network = Network.new('root')
        @network.parse_template(@root_scope.template)
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
            skip:             false
        }


        return params if tags.nil?

        tags = tags.lines.map(&:strip).select { |line| line.start_with?('<') }.map { |line| line[1..].strip }

        params[:skip] = tags.include? 'skip'

        fail_tag = tags.find { |tag| tag =~ /^fail.*$/ }

        params[:should_finish] = fail_tag.nil?

        if !params[:should_finish]
            params[:valid_exceptions] = _get_valid_exceptions(fail_tag)
        end

        params
    end

end
