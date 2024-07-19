def print_h(hash, pf = '')
    puts "#{pf}{"
    hashes, leaves = hash.partition { |_, v| v.is_a? Hash }

    width = leaves.to_h.keys.map(&:to_s).map(&:length).max

    new_pf = "#{pf}  "
    leaves.to_h.each do |k, v|
        puts "#{new_pf}#{k.to_s.ljust(width)}: #{v}"
    end

    hashes.to_h.each_value do |v|
        print_h(v, new_pf)
    end

    puts "#{pf}}"

    nil
end
