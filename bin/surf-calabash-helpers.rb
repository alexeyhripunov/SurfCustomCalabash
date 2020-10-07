require 'tempfile'
require 'json'
require "rubygems"

def msg(title, &block)
  Kernel.puts "\n" + "-"*10 + title + "-"*10
  block.call
  Kernel.puts "-"*10 + "-------" + "-"*10 + "\n"
end

def print_usage
  Kernel.puts <<EOF
  Usage: SurfCustomCalabash <command-name> [parameters] [options]
  <command-name> can be one of
    help
      prints more detailed help information.
    gen
      generate a features folder structure.
    update
      update infrastructure files in your project
    version
      prints the gem version

  <options> can be
    -v, --verbose
      Turns on verbose logging
EOF
end

def print_help
  print_usage
end

def is_json?(str)
  str[0..0] == '{'
end
