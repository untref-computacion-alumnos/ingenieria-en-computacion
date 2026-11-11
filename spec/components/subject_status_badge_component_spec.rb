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

  describe "availability" do
    it "shows an available subject with the label and the available status" do
      render_inline(described_class.new(subject: subject_record, status: "available"))
      expect(page).to have_css("[data-status='available']", text: I18n.t("subject_progresses.statuses.available"))
    end

    it "shows a blocked subject with its label, not only with a color" do
      render_inline(described_class.new(subject: subject_record, status: "blocked"))
      expect(page).to have_css("[data-status='blocked']", text: I18n.t("subject_progresses.statuses.blocked"))
    end
  end
end
