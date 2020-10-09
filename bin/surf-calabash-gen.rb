def surf_gen
  if File.exists?(@hierarchy)
    Kernel.puts "hierarchy is already created. Stopping..."
    exit 1
  end
  msg("Question") do
    Kernel.puts "I'm about to create a subdirectory called sources."
    Kernel.puts "Please hit return to confirm that's what you want."
  end
  exit 2 unless STDIN.gets.chomp == ''

  Kernel.puts("Please enter name autotest project:")
  file_name = gets.chomp
  file_name = "Change_it_to_your_own_project_name" if file_name == ""
  FileUtils.cp_r(@source_dir, File.join(FileUtils.pwd, file_name))
  msg("Info") do
      Kernel.puts "hierarchy was created. \n"
  end
end
