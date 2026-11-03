# frozen_string_literal: true

Given(
  "the study plan {string} has subjects in year {int} term {int} and year {int} term {int}"
) do |plan_year, *positions|
  plan = create(:study_plan, year: plan_year.to_i)
  @subjects_by_term = positions.each_slice(2).to_h do |year, term|
    [[year, term], create_list(:subject, 2, study_plan: plan, year: year, term: term)]
  end
end

When("I open the study plan {string}") do |year|
  visit study_plan_path(StudyPlan.find_by!(year: year.to_i))
end

Then("I should see year {int} term {int} with its subjects") do |year, term|
  section = find("section", text: I18n.t("study_plans.grid.term", year: year, term: term))
  @subjects_by_term.fetch([year, term]).each { |subject| expect(section).to have_text(subject.name) }
end

When("I open a study plan that does not exist") do
  visit study_plan_path(id: 0)
end

Then("I should see the not found page") do
  expect(page.status_code).to eq(404)
end
