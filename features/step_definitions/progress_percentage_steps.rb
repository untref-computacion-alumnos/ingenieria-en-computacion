# frozen_string_literal: true

Given("I am signed in as a student following a plan with {int} subjects") do |count|
  @plan = create(:study_plan, year: 2018)
  @subjects = create_list(:subject, count, study_plan: @plan)
  @student = create(:user, study_plan: @plan)
  log_in_with(@student.email, VALID_PASSWORD)
end

Given("I have {int} subjects approved and {int} promoted") do |approved, promoted|
  @subjects.first(approved).each do |subject|
    create(:subject_progress, user: @student, subject: subject, status: :approved)
  end
  @subjects.last(promoted).each do |subject|
    create(:subject_progress, user: @student, subject: subject, status: :promoted)
  end
end

Given("I opened the first subject of the plan from the grid") do
  visit study_plan_path(@plan)
  find("a[href='#{subject_path(@subjects.first)}']").click
  expect(page).to have_css("#subject_detail", text: @subjects.first.name)
  page.execute_script("window.sameDocument = true")
end

Then("I should see {int} of {int} subjects completed") do |completed, total|
  expect(find_by_id("progress_bar")).to have_text(I18n.t("curriculum.progress.counts", completed: completed,
                                                                                       total: total))
end

Then("I should see {int} percent") do |percent|
  expect(find_by_id("progress_bar")).to have_text(I18n.t("curriculum.progress.percent", percent: percent))
end
