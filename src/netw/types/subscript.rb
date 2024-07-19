# frozen_string_literal: true

class SubscriptRange
    attr_reader :start, :stop, :step

    def initialize(start = nil, stop = nil, step = nil)
        @start = start.nil? ? 0 : start
        @stop = stop
        @step = step
    end

    def size
        return -1 if right_sided?

        @stop - @start
    end

    def as_range
        return (@start..@start) if right_sided?

        return (@start..@stop) if @start == @stop

        (@start...@stop)
    end

    def right_sided?
        @stop.nil?
    end

    def ==(other)
        @start == other.start && @stop == other.stop
    end

    def inspect
        to_s
    end

    def to_s
        "#{@start}:#{@stop}"
    end
end

class SubscriptIndex
    def initialize(index)
        @index = index
    end

    def start
        @index
    end

    def stop
        nil
    end

    def step
        1
    end

    def size
        1
    end

    def as_range
        (@index..@index)
    end

    def right_sided?
        false
    end

    def ==(other)
        @index == other.instance_variable_get(:@index)
    end

    def inspect
        to_s
    end

    def to_s
        @index.to_s
    end
end
