require "bundler"

class Gem::Commands::UnusedCommand < Gem::Command
  def description
    "Show and remove unused gems and old versions of gems"
  end

  def arguments

  end

  def usage
    "#{program_name}"
  end

  def initialize
    super "unused", description

    add_option("-r", "--remove", "Remove all gems found by #{program_name}") do |value, options|
      options[:remove] = true
    end

    add_option("", "--branches BRANCH", "Set branch names to check for currently used gems. Space separated, surround with a string (\"master staging production\")") do |value, options|
      options[:branches] = value
    end
  end

  def execute
    if options[:branches].nil?
      puts "no branch names provided. using master, staging, and production as default."
      options[:branches] = %w(master staging production)
    else
      options[:branches] = options[:branches].split
    end
    find_unused_gems
    remove_unused_gems if options[:remove]
  end

  def find_unused_gems
    puts "I'm finding your unused gems...(not yet though)"
    options[:branches].each do |branch|
      `git co #{branch}`
      puts "======#{branch}======="
      bundle = ::Bundler::LockfileParser.new(File.read("Gemfile.lock"))
      bundle.specs.each do |spec|
        puts "#{spec.name} (#{spec.version})"
      end
    end
  end

  def remove_unused_gems
    puts "I'm removing your unused gems....mwuahahahha!!!"
  end
end