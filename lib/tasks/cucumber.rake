# frozen_string_literal: true

unless ARGV.any? { |a| a =~ /^gems/ }
  vendored_cucumber_bin = Dir[Rails.root.join("vendor/{gems,plugins}/cucumber*/bin/cucumber").to_s].first
  $LOAD_PATH.unshift("#{File.dirname(vendored_cucumber_bin)}/../lib") unless vendored_cucumber_bin.nil?
  begin
    require "cucumber/rake/task"
    namespace :cucumber do
      Cucumber::Rake::Task.new({ ok: "test:prepare" }, "Run features that should pass") do |t|
        t.binary = vendored_cucumber_bin
        t.fork = true
        t.profile = "default"
      end
      Cucumber::Rake::Task.new({ wip: "test:prepare" }, "Run features that are being worked on") do |t|
        t.binary = vendored_cucumber_bin
        t.fork = true
        t.profile = "wip"
      end
      Cucumber::Rake::Task.new({ rerun: "test:prepare" },
                               "Record failing features and run only them if any exist") do |t|
        t.binary = vendored_cucumber_bin
        t.fork = true
        t.profile = "rerun"
      end
      desc "Run all features"
      task all: %i[ok wip]
      task statsetup: :environment do
        require "rails/code_statistics"
        STATS_DIRECTORIES << ["Cucumber features", "features"] if File.exist?("features")
        CodeStatistics::TEST_TYPES << "Cucumber features" if File.exist?("features")
      end
    end
    desc "Alias for cucumber:ok"
    task cucumber: "cucumber:ok"
    task default: :cucumber
    task features: :cucumber do
      warn "*** The 'features' task is deprecated. See rake -T cucumber ***"
    end
    task "test:prepare" => :environment do
    end
    task stats: "cucumber:statsetup"
  rescue LoadError
    desc "cucumber rake task not available (cucumber not installed)"
    task cucumber: :environment do
      abort "Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin"
    end
  end
end
