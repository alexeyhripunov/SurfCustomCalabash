def surf_gen
  if File.exists?(@hierarchy)
    puts "hierarchy is already created. Stopping..."
    exit 1
  end
  msg("Question") do
    puts "I'm about to create a subdirectory called sources."
    puts "Please change name of it to name of your own project."
    puts "Please hit return to confirm that's what you want."
  end
  exit 2 unless STDIN.gets.chomp == ''

  FileUtils.cp_r(@source_dir, @hierarchy)
  msg("Info") do
      puts "hierarchy was created. \n"
  end
end
