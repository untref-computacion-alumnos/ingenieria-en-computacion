# frozen_string_literal: true

module GridHighlightHelpers
  def grid_card(name)
    find("a[data-subject-id='#{@subjects.fetch(name).id}']")
  end

  def select_in_grid(name)
    path = study_plan_path(@subjects.fetch(name).study_plan)
    visit path unless page.current_path == path
    grid_card(name).click
  end
end

World(GridHighlightHelpers)

Given("the subject {string} requires {string} and unlocks {string}") do |name, required_name, unlocked_name|
  plan = create(:study_plan)
  required = create(:subject, study_plan: plan, name: required_name, year: 1)
  selected = create(:subject, study_plan: plan, name: name, year: 2)
  unlocked = create(:subject, study_plan: plan, name: unlocked_name, year: 3)
  create(:prerequisite, subject: selected, required_subject: required)
  create(:prerequisite, subject: unlocked, required_subject: selected)
  @subjects = [required, selected, unlocked].index_by(&:name)
end

Given("I selected the subject {string} in the grid") do |name|
  select_in_grid(name)
  expect(page).to have_css("a[data-highlight='selected']")
end

When("I select the subject {string} in the grid") do |name|
  select_in_grid(name)
end

When("I focus the subject {string} in the grid") do |name|
  path = study_plan_path(@subjects.fetch(name).study_plan)
  visit path unless page.current_path == path
  page.execute_script("arguments[0].focus()", grid_card(name))
end

Then("{string} should be highlighted as a prerequisite") do |name|
  card = "a[data-subject-id='#{@subjects.fetch(name).id}'][data-highlight='requires']"
  expect(page).to have_css(card)
end

Then("{string} should be highlighted as unlocked") do |name|
  card = "a[data-subject-id='#{@subjects.fetch(name).id}'][data-highlight='unlocks']"
  expect(page).to have_css(card)
end

Then("no subject should be highlighted") do
  expect(page).to have_no_css("a[data-highlight]")
end
