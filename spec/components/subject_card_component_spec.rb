# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectCardComponent, type: :component do
  let(:subject_record) { build_stubbed(:subject, name: "Álgebra I") }

  before { render_inline(described_class.new(subject: subject_record)) }

  it "is a link to the subject detail, so it can be focused with the keyboard" do
    expect(page).to have_link("Álgebra I", href: "/subjects/#{subject_record.id}")
  end

  it "opens the detail in the side panel" do
    expect(page).to have_css("a[data-turbo-frame='subject_detail']", text: "Álgebra I")
  end

  it "shows the subject code" do
    expect(page).to have_text(subject_record.code)
  end
end
