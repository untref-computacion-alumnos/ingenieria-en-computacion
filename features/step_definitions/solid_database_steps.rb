# frozen_string_literal: true

SOLID_QUEUE_TABLES = %w[
  solid_queue_batch_executions solid_queue_batches solid_queue_blocked_executions
  solid_queue_claimed_executions solid_queue_failed_executions solid_queue_jobs
  solid_queue_pauses solid_queue_processes solid_queue_ready_executions
  solid_queue_recurring_executions solid_queue_recurring_tasks
  solid_queue_scheduled_executions solid_queue_semaphores
].freeze

When("I list the tables of the primary database") do
  @tables = ActiveRecord::Base.connection.tables
end

Then("the list includes the Solid Queue tables") do
  expect(@tables).to include(*SOLID_QUEUE_TABLES)
end

Then("the list includes the Solid Cache table") do
  expect(@tables).to include("solid_cache_entries")
end

Then("the list includes the Solid Cable table") do
  expect(@tables).to include("solid_cable_messages")
end
