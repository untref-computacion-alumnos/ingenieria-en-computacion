# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlanGridComponent, type: :component do
  let(:subjects_by_term) do
    {
      [1, 1] => [build_stubbed(:subject, name: "Álgebra I")],
      [1, 2] => [build_stubbed(:subject, name: "Álgebra II")]
    }
  end

  before { render_inline(described_class.new(subjects_by_term: subjects_by_term)) }

  it "renders one column per year and term with its subjects" do
    term1 = /#{I18n.t("study_plans.grid.term", year: 1, term: 1)}.*Álgebra I/m
    term2 = /#{I18n.t("study_plans.grid.term", year: 1, term: 2)}.*Álgebra II/m
    expect(page).to have_css("section", text: term1).and have_css("section", text: term2)
  end

  it "gives every subject a card that links to its detail" do
    expect(page).to have_css("a[data-turbo-frame='subject_detail']", count: 2)
  end

  it "scrolls horizontally on narrow screens" do
    expect(page).to have_css("div.overflow-x-auto")
  end

  it "is controlled by the grid-highlight controller" do
    expect(page).to have_css("div.overflow-x-auto[data-controller='grid-highlight']")
  end

  describe "statuses" do
    let(:subject_record) { create(:subject, year: 1, term: 1) }
    let(:subjects_by_term) { { [1, 1] => [subject_record] } }

    it "shows the status of each subject for a signed-in user" do
      statuses = Hash.new("pending").merge(subject_record.id => "approved")
      render_inline(described_class.new(subjects_by_term: subjects_by_term, statuses: statuses))
      expect(page).to have_css("[data-status='approved']")
    end

    it "shows pending for a subject the user never marked" do
      render_inline(described_class.new(subjects_by_term: subjects_by_term, statuses: Hash.new("pending")))
      expect(page).to have_css("[data-status='pending']")
    end

    it "shows no status at all for a visitor" do
      render_inline(described_class.new(subjects_by_term: subjects_by_term))
      expect(page).to have_no_css("[data-status]")
    end
  end
end
