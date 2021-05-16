def compare(cmp, out)
  return true if cmp == out
  return false unless out
  return false unless cmp.lines.size == out.lines.size

  cmp.lines.zip(out.lines) do |cmp_line, out_line|
    cmp_cells = cmp_line.split('|')
    out_cells = out_line.split('|')
    return false unless cmp_cells.size == out_cells.size
    return false unless cmp_cells.zip(out_cells).all? do |cmp_cell, out_cell|
      cmp_cell.chars.uniq == ['*'] || cmp_cell == out_cell
    end
  end

  true
end

chap = ARGV.first
chapters = chap ? [chap] : (0..11).map { |c| "%02d" % c }

chapters.each do |c|
  directory = File.join(__dir__, c)
  problems = Dir.glob(File.join(directory, '**', '*.cmp')).sort
  next if problems.empty?

  puts "#{c}:"

  problems.each do |x|
    basename = x.sub(directory + File::SEPARATOR, "").chomp(".cmp")
    cmp = open(File.join(directory, "#{basename}.cmp")).read.gsub(/\r\n/, "\n") rescue next
    out = open(File.join(directory, "#{basename}.out")).read rescue nil
    result = compare(cmp, out) ? "✅" : "❌"

    puts "\t#{basename} - #{result}"
  end

  puts
end
