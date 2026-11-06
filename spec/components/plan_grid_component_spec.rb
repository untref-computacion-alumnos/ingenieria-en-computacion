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
end
