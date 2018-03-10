require 'filesize'
require 'terminal-table'
require 'highline'
require 'sys/filesystem'

class DirSizer
  def self.execute(dir)
    unless Dir.exist?(dir) && File.directory?(dir)
      puts "not a directory: #{dir}"
      exit(3)
    end
    init_dirs_to_ignore(dir)

    puts "Calculating size of directory #{dir}"
    size_hash = calculate_size_hash(dir)
    contents = calculate_size(size_hash)
    puts 'done'

    browse_contents(contents)
  end

  def self.init_dirs_to_ignore(dir)
    @dirs_to_ignore = ['/dev', '/private/var/db/ConfigurationProfiles/Store', '/private/var/folders']
    Sys::Filesystem.mounts{ |mount|
      @dirs_to_ignore << mount.mount_point unless mount.mount_point == dir
    }
  end

  def self.calculate_size_hash(dir)
    #print '.'
    r = { :dirs => {}, :files => {}, :dir => dir}
    Dir.entries(dir).each { |e|
      next if ['.', '..'].include? e
      t = File.join(dir, e)
      next if File.symlink? t
      next if @dirs_to_ignore.include? t
      if File.directory?(t)
        r[:dirs][t] = calculate_size_hash(t)
      else
        r[:files][t] = File.stat(t).size
      end
    }
    r
  end

  def self.calculate_size(hash)
    t = {}
    hash[:dirs].each { |d,h|
      size_d = calculate_size(h)
      t[d] = size_d
    }
    size_dirs = t.values.map{ |v|
      v[:total]
    }.inject { |sum, n| sum + n } || 0
    size_files = hash[:files].values.inject { |sum, n| sum + n } || 0
    { :dirs => t, :total => size_files + size_dirs, :dirs_by_size => t.sort_by{|d,h| h[:total] }.reverse, :dir => hash[:dir] }
  end

  def self.browse_contents(content)
    cli = HighLine.new
    contents = content
    back_stack = []

    loop do
      print_table contents
      a = cli.ask("Type number of directory? ('..' for parent directory, 'e' to exit)")
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

  def self.print_table(contents)
    output = []
    output << ['', Filesize.from("#{contents[:total]} B").pretty, contents[:dir]]
    contents[:dirs_by_size].each_with_index{ |t,i|
      s = Filesize.from("#{t[1][:total]} B").pretty
      output << [i, s, t[0]]
    }
    puts Terminal::Table.new :headings => ['Cmd', 'Dir', 'Size'], :rows => output
  end

end
