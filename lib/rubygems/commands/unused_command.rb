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

    add_option("", "--branches BRANCH",
               "Set branch names to check for currently used gems.
                Space separated, surround with a string (\"master staging production\")"
    ) do |value, options|
      options[:branches] = value
    end

    add_option("", "--exclude GEM",
               "Set gem names to exclude from check.
                These gems should really be installed in the global gemset.
                Surround with a string for multiples (\"gem_a gem_b gem_c\")"
    ) do |value, options|
      options[:excluded_gems] = value
    end

    add_option("-q", "--quiet",
              "Make this script perform its work quietly"
    ) do |value, options|
      options[:quiet] = true
    end
  end

  def execute
    if options[:branches].nil?
      log "no branch names provided. using master, staging, and production as default."
      options[:branches] = %w(master staging production)
    else
      options[:branches] = options[:branches].split
    end
    find_unused_gems
    remove_unused_gems if options[:remove]
  end

  def find_unused_gems
    retrieve_requirements
    retrieve_installed

    @unneeded = @installed.delete_if do |installed_spec|
      # remove any required installed gems
      @requirements.any? do |spec|
        spec.name == installed_spec.name &&
          spec.version == installed_spec.version
      end
    end

    log "====REMOVE THESE GEMS===="
    @unneeded.each do |bad_gem|
      log "#{bad_gem.name} #{bad_gem.version}"
    end
  end

  def retrieve_requirements
    read_requirements
    setup_excluded_gems
    @requirements.uniq! { |spec| "#{spec.name} #{spec.version}" }
    log "These are the requirements of your lockfiles:"
    @requirements.each do |spec|
      log "#{spec.name} #{spec.version}"
    end
    # TODO: somewhere we need to skip/omit those excluded gems
  end

  def retrieve_installed
    @installed = Gem::Specification.find_all do |installed_spec|
      !installed_spec.gem_dir.match /@global/
    end.uniq { |spec| "#{spec.name} #{spec.version}" }
  end

  def setup_excluded_gems
    if options[:excluded_gems].nil?
      log "Not excluding any gems."
    else
      options[:excluded_gems] = options[:excluded_gems].split
      log "Excluding the following gems: #{options[:excluded_gems]}"
    end
  end

  def read_requirements
    @requirements = []
    options[:branches].each do |branch|
      `git co #{branch}`
      bundle = ::Bundler::LockfileParser.new(File.read("Gemfile.lock"))
      @requirements.concat bundle.specs
    end
  end

  def remove_unused_gems
    log "I'm removing your unused gems....mwuahahahha!!!"
  end

  def log message
    puts message unless options[:quiet]
  end
end