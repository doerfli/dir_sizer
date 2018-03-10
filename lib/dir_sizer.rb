require 'filesize'
require 'terminal-table'
require 'highline'

class DirSizer
  def self.execute(dir)
    unless Dir.exist?(dir) && File.directory?(dir)
      puts "not a directory: #{dir}"
      exit(3)
    end
    puts "Calculating size of directory #{dir}"
    size_hash = calculate_size_hash(dir)
    contents = calculate_size(size_hash)
    puts 'done'

    browse_contents(contents)
  end

  def self.calculate_size_hash(dir)
    print '.'
    r = { :dirs => {}, :files => {}, :dir => dir}
    Dir.entries(dir).each { |e|
      next if ['.', '..'].include? e
      t = File.join(dir, e)
      if File.directory?(t)
        r[:dirs][t] = calculate_size_hash(t)
      else
        r[:files][t] = File.stat(t).size
      end
    }
    r
  end

  def self.calculate_size(hash)
    r = { :dirs => {}, :total => 0, :dirs_by_size => nil, :dir => hash[:dir] }
    size_files = hash[:files].values.inject { |sum, n| sum + n } || 0
    hash[:dirs].each { |d,h|
      size_d = calculate_size(h)
      r[:dirs][d] = size_d
    }
    size_dirs = r[:dirs].values.map{ |v|
      v[:total]
    }.inject { |sum, n| sum + n } || 0
    r[:total] = size_files + size_dirs
    r[:dirs_by_size] = r[:dirs].sort_by{|d,h| h[:total] }.reverse
    r
  end

  def self.browse_contents(content)
    cli = HighLine.new
    contents = content
    back_stack = []

    loop do
      output = []
      output << ['.',Filesize.from("#{contents[:total]} B").pretty,contents[:dir]]
      i = 0
      contents[:dirs_by_size].each{ |t|
        s = Filesize.from("#{t[1][:total]} B").pretty
        output << [i,s,t[0]]
        i = i + 1
      }
      table = Terminal::Table.new :headings => ['Cmd', 'Dir', 'Size'], :rows => output
      puts table

      a = cli.ask("Number of directory? ('e' to exit)")

      case a
      when 'e'
        break
      when '..'
        contents = back_stack.pop
      else
        back_stack.push contents
        next_dir = contents[:dirs_by_size][a.to_i][0]
        contents = contents[:dirs][next_dir]
      end
    end
  end

end
