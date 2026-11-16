# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectGradeFormComponent, type: :component do
  let(:subject_record) { build_stubbed(:subject) }

  def render_form(status: :approved, saved: false, **attributes)
    progress = build_stubbed(:subject_progress, subject: subject_record, status: status, **attributes)
    render_inline(described_class.new(subject: subject_record, progress: progress, saved: saved))
  end

  it "has a stable id so a Turbo Stream can replace it" do
    render_form
    expect(page).to have_css("#grade_form_subject_#{subject_record.id}")
  end

  it "shows the form for an approved subject" do
    render_form
    expect(page).to have_css("form[action='/subjects/#{subject_record.id}/grade']")
  end

  it "shows the form for a promoted subject" do
    render_form(status: :promoted)
    expect(page).to have_css("form")
  end

  %i[pending in_progress regular].each do |status|
    it "does not show the form for a #{status} subject" do
      render_form(status: status)
      expect(page).to have_no_css("form")
    end
  end

  it "keeps an empty container when there is no progress yet" do
    render_inline(described_class.new(subject: subject_record, progress: nil, saved: false))
    expect(page).to have_xpath("//div[@id='grade_form_subject_#{subject_record.id}'][not(*)]")
  end

  it "labels the grade field" do
    render_form
    expect(page).to have_field(I18n.t("subject_grades.form.grade"), type: "number")
  end

  it "limits the grade field to 1..10 with one decimal" do
    render_form
    expect(page).to have_css("input[name='subject_progress[grade]'][min='1'][max='10'][step='0.1']")
  end

  it "shows the saved grade without extra zeros" do
    render_form(grade: 8)
    expect(page).to have_field(I18n.t("subject_grades.form.grade"), with: "8")
  end

  it "shows a decimal grade" do
    render_form(grade: 7.5)
    expect(page).to have_field(I18n.t("subject_grades.form.grade"), with: "7.5")
  end

  it "labels the date field" do
    render_form
    expect(page).to have_field(I18n.t("subject_grades.form.approved_on"), type: "date")
  end

  it "shows the saved date" do
    render_form(approved_on: Date.new(2024, 12, 10))
    expect(page).to have_field(I18n.t("subject_grades.form.approved_on"), with: "2024-12-10")
  end

  it "does not let the date go past today" do
    render_form
    expect(page).to have_css("input[type='date'][max='#{Date.current.iso8601}']")
  end

  it "asks about the final exam only for a promoted subject" do
    render_form(status: :promoted)
    expect(page).to have_field(I18n.t("subject_grades.form.final_exam_taken"), type: "checkbox")
  end

  it "does not ask about the final exam for an approved subject" do
    render_form
    expect(page).to have_no_field(I18n.t("subject_grades.form.final_exam_taken"))
  end

  it "has a save button" do
    render_form
    expect(page).to have_button(I18n.t("subject_grades.form.save"))
  end

  it "lists the errors in an alert" do
    progress = build_stubbed(:subject_progress, subject: subject_record, status: :approved, grade: 11)
    progress.validate
    render_inline(described_class.new(subject: subject_record, progress: progress, saved: false))
    expect(page).to have_css("[role='alert']",
                             text: I18n.t("activerecord.errors.models.subject_progress.attributes.grade.invalid_grade"))
  end

  it "does not show an alert when there are no errors" do
    render_form
    expect(page).to have_no_css("[role='alert']")
  end

  it "confirms a saved record with a status message" do
    render_form(saved: true)
    expect(page).to have_css("[role='status']", text: I18n.t("subject_grades.form.saved"))
  end

  it "does not confirm anything when nothing was saved" do
    render_form
    expect(page).to have_no_css("[role='status']")
  end
end
