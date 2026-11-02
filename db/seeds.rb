# frozen_string_literal: true

Rails.root.glob("db/seeds/plans/*.yml").sort.each do |path|
  Seeds::PlanLoader.new(path).call
end
