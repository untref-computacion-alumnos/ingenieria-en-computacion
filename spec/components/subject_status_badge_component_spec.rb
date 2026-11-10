# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectStatusBadgeComponent, type: :component do
  let(:subject_record) { build_stubbed(:subject) }

  def render_badge(status)
    render_inline(described_class.new(subject: subject_record, status: status))
  end

  SubjectProgress.statuses.each_key do |status|
    describe "the #{status} status" do
      before { render_badge(status) }

      it "shows its name, so color is never the only cue" do
        expect(page).to have_text(I18n.t("subject_progresses.statuses.#{status}"))
      end

      it "exposes the status for the card" do
        expect(page).to have_css("span[data-status='#{status}']")
      end

      it "uses the color token of the status with its content color" do
        expect(page).to have_css("span.bg-status-#{status.dasherize}.text-status-content")
      end
    end
  end

  it "has an id so a Turbo Stream can replace it" do
    render_badge("approved")
    expect(page).to have_css("span#status_subject_#{subject_record.id}")
  end
end
