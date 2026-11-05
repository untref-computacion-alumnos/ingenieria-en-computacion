# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Style guide: colors" do # rubocop:disable RSpec/DescribeClass
  let(:globs) do
    %w[app/views app/components app/helpers app/javascript app/assets/stylesheets].map do |dir|
      Rails.root.join(dir, "**/*.{erb,rb,js,css}")
    end
  end
  let(:palette) do
    "slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|" \
      "violet|purple|fuchsia|pink|rose"
  end
  let(:utilities) { "bg|text|border|ring|fill|stroke|from|via|to|outline|divide|shadow|accent|caret|decoration" }
  let(:forbidden) do
    [
      [/#\h{8}\b|#\h{6}\b/, "hex color"],
      [/\b(?:rgb|rgba|hsl|hsla|oklch|oklab|lab|lch)\(/, "color function"],
      [/\b(?:#{utilities})-(?:#{palette})-\d{2,3}\b/, "Tailwind palette color"],
      [/\b(?:#{utilities})-(?:black|white)\b/, "black or white"]
    ]
  end

  def offences_in(path)
    File.readlines(path).each_with_index.flat_map do |line, index|
      forbidden.filter_map do |pattern, label|
        "#{path.relative_path_from(Rails.root)}:#{index + 1} #{label}: #{line.strip}" if line.match?(pattern)
      end
    end
  end

  it "uses theme tokens instead of literal colors" do
    paths = globs.flat_map { |glob| Dir[glob] }.map { |path| Pathname(path) }
    expect(paths.flat_map { |path| offences_in(path) }).to be_empty
  end

  it "detects literal colors (guards the guard)" do
    sample = Tempfile.new(["sample", ".erb"])
    sample.write(%(<div class="bg-blue-500 text-white" style="color: #1d5a9e"></div>\n))
    sample.flush
    expect(offences_in(Pathname(sample.path)).size).to eq(3)
    sample.close!
  end
end
