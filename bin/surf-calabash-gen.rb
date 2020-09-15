def surf_gen
  if File.exists?(@hierarchy)
    Kernel.puts "hierarchy is already created. Stopping..."
    exit 1
  end
  msg("Question") do
    Kernel.puts "I'm about to create a subdirectory called sources."
    Kernel.puts "Please change name of it to name of your own project."
    Kernel.puts "Please hit return to confirm that's what you want."
  end
  exit 2 unless STDIN.gets.chomp == ''

  FileUtils.cp_r(@source_dir, @hierarchy)
  msg("Info") do
      Kernel.puts "hierarchy was created. \n"
  end
end
