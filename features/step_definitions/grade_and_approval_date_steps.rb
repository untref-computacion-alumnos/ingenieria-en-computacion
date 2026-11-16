# frozen_string_literal: true

GRADE_ERROR_KEY = "activerecord.errors.models.subject_progress.attributes.grade.invalid_grade"
DATE_ERROR_KEY = "activerecord.errors.models.subject_progress.attributes.approved_on.future"

def open_grade_form(name)
  visit study_plan_path(@plan)
  click_link name
  expect(page).to have_css("#subject_detail", text: name)
end

def save_grade_form(name, grade: nil, date: nil)
  open_grade_form(name)
  fill_in I18n.t("subject_grades.form.grade"), with: grade if grade
  fill_in I18n.t("subject_grades.form.approved_on"), with: date if date
  click_button I18n.t("subject_grades.form.save")
end

When("I save the grade {int} and the date {string} for {string}") do |grade, date, name|
  save_grade_form(name, grade: grade, date: date)
end

When("I save the grade {int} for {string}") do |grade, name|
  save_grade_form(name, grade: grade)
end

When("I save a date in the future for {string}") do |name|
  save_grade_form(name, date: Date.current.next_day.iso8601)
end

Then("the subject {string} should show grade {int} and that date") do |name, grade|
  open_grade_form(name)
  expect(page).to have_field(I18n.t("subject_grades.form.grade"), with: grade.to_s)
  expect(page).to have_field(I18n.t("subject_grades.form.approved_on"), with: "2024-12-10")
end

Then("I should see an error about the grade") do
  expect(page).to have_text(I18n.t(GRADE_ERROR_KEY))
end

Then("I should see an error about the date") do
  expect(page).to have_text(I18n.t(DATE_ERROR_KEY))
end
