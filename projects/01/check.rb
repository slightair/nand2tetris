problems = Dir.glob('*.hdl').sort
problems.each do |x|
    basename = File.basename(x, ".hdl")
    cmp = open("#{basename}.cmp").read.gsub(/\r\n/, "\n")
    out = open("#{basename}.out").read rescue nil
    result = cmp == out ? "✅" : "❌"

    puts "#{x} - #{result}"
end
