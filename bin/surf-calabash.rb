class Surf_Calabash
  def self.hi
    Kernel.puts "It's SurfCustomCalabash gem"
  end

  def gen
    if File.exists?(@hierarchy)
      Kernel.puts "hierarchy is already exists. Stopping..."
      exit 1
    end
    msg("Question") do
      Kernel.puts "I'm about to create a directory called sources."
    end
    exit 2 unless STDIN.gets.chomp == ''

    FileUtils.cp_r(@source_dir, @hierarchy)

    msg("Info") do
      Kernel.puts "hierarchy directories are created. \n"
    end
  end
end