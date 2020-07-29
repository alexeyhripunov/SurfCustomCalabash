class Surf_Calabash
  def self.hi
    puts "It's SurfCustomCalabash gem"
  end

  def gen
    if File.exists?(@hierarchy)
      puts "hierarchy is already exists. Stopping..."
      exit 1
    end
    msg("Question") do
      puts "I'm about to create a directory called sources."
    end
    exit 2 unless STDIN.gets.chomp == ''

    FileUtils.cp_r(@source_dir, @hierarchy)

    msg("Info") do
      puts "hierarchy directories are created. \n"
    end
  end
end