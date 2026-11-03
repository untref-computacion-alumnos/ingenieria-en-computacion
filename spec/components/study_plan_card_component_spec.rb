# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudyPlanCardComponent, type: :component do
  def render_card(active:)
    render_inline(described_class.new(year: 2022, subjects_count: 4, active: active))
  end

  it "shows the plan year and its number of subjects" do
    render_card(active: false)
    expect(page).to have_text(I18n.t("study_plans.card.title",
                                     year: 2022)).and have_text(I18n.t("study_plans.card.subjects", count: 4))
  end

  it "shows the active badge when the plan is the active one" do
    render_card(active: true)
    expect(page).to have_text(I18n.t("study_plans.card.active"))
  end

  it "hides the active badge otherwise" do
    render_card(active: false)
    expect(page).to have_no_text(I18n.t("study_plans.card.active"))
  end
end
