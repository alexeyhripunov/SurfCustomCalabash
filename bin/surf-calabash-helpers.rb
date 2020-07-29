require 'tempfile'
require 'json'
require "rubygems"

def msg(title, &block)
  puts "\n" + "-"*10 + title + "-"*10
  block.call
  puts "-"*10 + "-------" + "-"*10 + "\n"
end

def print_usage
  puts <<EOF
  Usage: SurfCustomCalabash <command-name> [parameters] [options]
  <command-name> can be one of
    help
      prints more detailed help information.
    gen
      generate a features folder structure.
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
