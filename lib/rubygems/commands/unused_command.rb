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
    @requirements = []
    options[:branches].each do |branch|
      `git co #{branch}`
      bundle = ::Bundler::LockfileParser.new(File.read("Gemfile.lock"))
      # this is omitting development dependencies
      @requirements.concat bundle.specs
    end
    @requirements.uniq! {|spec| "#{spec.name} #{spec.version}" }
    puts "These are the requirements of your lockfiles:"
    @requirements.each do |spec|
      puts "#{spec.name} #{spec.version}"
    end
    # now we need to find all the gems in the gemset
    @installed = []
    # TODO: we need to skip any that are installed in the global gemset
    Gem::Specification.find_all do |installed_spec|
      @installed << installed_spec
    end
    @installed.uniq! {|spec| "#{spec.name} #{spec.version}" }
    @unneeded = @installed.delete_if do |installed_spec|
      @requirements.any? {|spec| spec.name == installed_spec.name && spec.version == installed_spec.version}
    end
    puts "====REMOVE THESE GEMS===="
    @unneeded.each do |bad_gem|
      puts "#{bad_gem.name} #{bad_gem.version}"
    end
  end

  def remove_unused_gems
    puts "I'm removing your unused gems....mwuahahahha!!!"
  end
end