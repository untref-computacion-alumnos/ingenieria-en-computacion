# frozen_string_literal: true

require "rails_helper"

RSpec.describe LegalSectionComponent, type: :component do
  def render_section
    render_inline(described_class.new(id: "data_section", title: "Section title")) { "Section body" }
  end

  it "titles the section with an h2" do
    render_section
    expect(page).to have_css("section h2#data_section", text: "Section title")
  end

  it "labels the section with its title" do
    render_section
    expect(page).to have_css("section[aria-labelledby='data_section']")
  end

  it "renders the content under the title" do
    render_section
    expect(page).to have_css("section", text: "Section body")
  end
end
