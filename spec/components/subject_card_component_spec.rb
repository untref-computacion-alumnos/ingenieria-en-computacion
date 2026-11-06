# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectCardComponent, type: :component do
  let(:subject_record) { build_stubbed(:subject, name: "Álgebra I") }

  def render_card(record = subject_record)
    render_inline(described_class.new(subject: record))
  end

  it "is a link to the subject detail, so it can be focused with the keyboard" do
    render_card
    expect(page).to have_link("Álgebra I", href: "/subjects/#{subject_record.id}")
  end

  it "opens the detail in the side panel" do
    render_card
    expect(page).to have_css("a[data-turbo-frame='subject_detail']", text: "Álgebra I")
  end

  it "shows the subject code" do
    render_card
    expect(page).to have_text(subject_record.code)
  end

  describe "data for the highlight" do
    let(:plan) { create(:study_plan) }
    let(:record) { create(:subject, study_plan: plan, year: 2) }

    it "carries its own id" do
      render_card(record)
      expect(page).to have_css("a[data-subject-id='#{record.id}']")
    end

    context "when it has prerequisites" do
      let(:required) { create_list(:subject, 2, study_plan: plan) }

      before do
        required.each { |subject| create(:prerequisite, subject: record, required_subject: subject) }
      end

      it "lists the ids of its prerequisites, separated by spaces" do
        render_card(record.reload)
        expect(page).to have_css("a[data-required-ids='#{required.map(&:id).sort.join(" ")}']")
      end
    end

    it "has an empty list when it requires nothing" do
      render_card(record)
      expect(page).to have_css("a[data-required-ids='']")
    end

    it "is a target of the controller and toggles the highlight on click" do
      render_card(record)
      expect(page).to have_css("a[data-grid-highlight-target='card'][data-action='click->grid-highlight#toggle']")
    end
  end
end
