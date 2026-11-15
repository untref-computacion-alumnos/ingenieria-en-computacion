# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressBarComponent, type: :component do
  def render_bar(statuses)
    render_inline(described_class.new(progress: Curriculum::ProgressSummary.new(statuses: statuses)))
  end

  let(:statuses) { { 1 => "approved", 2 => "promoted", 3 => "available", 4 => "blocked" } }

  it "has a stable id so a Turbo Stream can replace it" do
    render_bar(statuses)
    expect(page).to have_css("#progress_bar")
  end

  it "shows the completed and total subjects as text" do
    render_bar(statuses)
    expect(page).to have_text(I18n.t("curriculum.progress.counts", completed: 2, total: 4))
  end

  it "shows the percentage as text" do
    render_bar(statuses)
    expect(page).to have_text(I18n.t("curriculum.progress.percent", percent: 50))
  end

  it "fills a daisyUI progress element with the percentage" do
    render_bar(statuses)
    expect(page).to have_css("progress.progress[value='50'][max='100']")
  end

  it "names the progress element for screen readers" do
    render_bar(statuses)
    expect(page).to have_css("progress[aria-labelledby='progress_bar_title']")
  end

  it "titles the section" do
    render_bar(statuses)
    expect(page).to have_css("h2#progress_bar_title", text: I18n.t("curriculum.progress.title"))
  end

  it "shows an empty bar for a student without progress" do
    render_bar(1 => "available", 2 => "blocked")
    expect(page).to have_css("progress[value='0']")
  end
end
