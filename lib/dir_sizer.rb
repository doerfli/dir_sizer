require 'filesize'
require 'terminal-table'

class DirSizer
  def self.execute(dir)
    unless Dir.exist?(dir) && File.directory?(dir)
      puts "not a directory: #{dir}"
      exit(3)
    end
    puts "Calculating size of directory #{dir}"
    size_hash = calculate_size_hash(dir)
    sizes = calculate_size(size_hash)
    puts 'done'

    output = []
    output << ['0',Filesize.from("#{sizes[:total]} B").pretty,dir]
    i = 0
    sizes[:dirs_by_size].each{ |t|
      i = i+1
      s = Filesize.from("#{t[1][:total]} B").pretty
      output << [i,s,t[0]]
    }

    table = Terminal::Table.new :headings => ['Cmd', 'Dir', 'Size'], :rows => output
    puts table
  end

  def self.calculate_size_hash(dir)
    print '.'
    r = { :dirs => {}, :files => {}}
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
    r = { :dirs => {}, :total => 0, :dirs_by_size => nil }
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

end
