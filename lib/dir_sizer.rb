require 'filesize'

class DirSizer
  def self.execute(dir)
    unless Dir.exist?(dir) && File.directory?(dir)
      puts "not a directory: #{dir}"
      exit(3)
    end
    puts "Calculating size of directory #{dir}"
    size_hash = calculate_size_hash(dir)
    size = calculate_size(size_hash)
    puts "!"
    puts "the size is #{Filesize.from("#{size} B").pretty}"
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

  def self.calculate_size(h)
    size_files = h[:files].values.inject { |sum, n| sum + n } || 0
    size_dirs = h[:dirs].values.map { |d| calculate_size(d) }.inject { |sum, n| sum + n } || 0
    size_files + size_dirs
  end

end
