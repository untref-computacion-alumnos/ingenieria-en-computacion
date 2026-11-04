# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectCardComponent, type: :component do
  before { render_inline(described_class.new(name: "Álgebra I")) }

  it "shows the subject name" do
    expect(page).to have_text("Álgebra I")
  end

  it "can be focused with the keyboard" do
    expect(page).to have_css("[tabindex='0']", text: "Álgebra I")
  end
end
