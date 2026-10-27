# frozen_string_literal: true

CI.run do
  step "Setup", "bin/setup --skip-server"
  step "Lint", "bin/lint"
  step "Security", "bin/security"
  step "Advisory", "bin/advisory"
  step "Test", "bin/test"
end
