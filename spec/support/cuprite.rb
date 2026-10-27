# frozen_string_literal: true

require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  options = File.exist?("/.dockerenv") || ENV["CI"] ? { "no-sandbox" => nil } : {}
  Capybara::Cuprite::Driver.new(app, window_size: [1280, 800], browser_options: options)
end

Capybara.javascript_driver = :cuprite
