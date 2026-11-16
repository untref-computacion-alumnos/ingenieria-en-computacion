# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectDetailComponent, type: :component do
  let(:required) { build_stubbed(:subject, name: "Álgebra I") }
  let(:subject_record) do
    build_stubbed(:subject, name: "Álgebra II", year: 1, term: 2, hours: 96, credits: nil)
  end

  before do
    allow(subject_record).to receive(:required_subjects).and_return([required])
    render_inline(described_class.new(subject: subject_record))
  end

  it "moves the focus to the heading when it opens in the panel" do
    expect(page).to have_css("h2[autofocus][tabindex='-1']", text: "Álgebra II")
  end

  it "shows only the facts that are known" do
    expect(page).to have_text(I18n.t("subjects.detail.hours")).and have_no_text(I18n.t("subjects.detail.credits"))
  end

  it "links each prerequisite to its detail inside the same frame" do
    expect(page).to have_css("li a[href='/subjects/#{required.id}']", text: "Álgebra I")
  end

  it "includes the status picker" do
    render_inline(described_class.new(subject: subject_record, status: "regular"))
    expect(page).to have_css("section#status_picker_subject_#{subject_record.id}")
  end

  it "passes the missing prerequisites to the status picker" do
    required = build_stubbed(:subject, name: "Álgebra")
    render_inline(described_class.new(subject: subject_record, status: "pending", missing: [required]))
    expect(page).to have_css("[role='note']", text: "Álgebra")
  end

  it "includes the container of the grade form" do
    expect(page).to have_css("#grade_form_subject_#{subject_record.id}")
  end

  it "shows the grade form to a student who approved the subject" do
    progress = build_stubbed(:subject_progress, subject: subject_record, status: :approved)
    render_inline(described_class.new(subject: subject_record, status: "approved", progress: progress))
    expect(page).to have_css("form[action='/subjects/#{subject_record.id}/grade']")
  end

  it "does not show the grade form when there is no progress" do
    expect(page).to have_no_css("form[action$='/grade']")
  end
end
