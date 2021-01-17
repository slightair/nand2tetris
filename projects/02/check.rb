problems = Dir.glob(File.join(__dir__, '*.hdl')).sort

problems.each do |x|
    basename = File.basename(x, ".hdl")
    cmp = open(File.join(__dir__, "#{basename}.cmp")).read.gsub(/\r\n/, "\n")
    out = open(File.join(__dir__, "#{basename}.out")).read rescue nil
    result = cmp == out ? "✅" : "❌"

    puts "#{basename} - #{result}"
end
