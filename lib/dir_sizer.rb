#require 'dir'

class DirSizer
  def self.execute(dir)
    unless Dir.exist?(dir) && File.directory?(dir)
      puts "not a directory: #{dir}"
      exit(3)
    end
    puts "Calculating size of directory #{dir}"
    size = size(dir)
    puts "the size is #{size} bytes"
  end

  def self.size(dir)
    puts "sizing directory #{dir}"
    Dir.entries(dir).map { |e|
      next if ['.', '..'].include? e
      t = File.join(dir, e)
      if File.directory?(t)
        size(t)
      else
        #puts "sizing file #{t}"
        File.stat(t).size
      end
    }.select{|t| !t.nil? }.inject{ |sum,n| sum + n }
  end
end
