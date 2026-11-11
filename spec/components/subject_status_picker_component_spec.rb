# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectStatusPickerComponent, type: :component do
  let(:subject_record) { build_stubbed(:subject) }

  def render_picker(status)
    render_inline(described_class.new(subject: subject_record, status: status))
  end

  it "has an id so a Turbo Stream can replace it" do
    render_picker("pending")
    expect(page).to have_css("section#status_picker_subject_#{subject_record.id}")
  end

  it "has a heading and a labeled group" do
    render_picker("pending")
    expect(page).to have_css("h3", text: I18n.t("subject_progresses.picker.title"))
      .and have_css("[role='group'][aria-label='#{I18n.t("subject_progresses.picker.label")}']")
  end

  it "offers one button per status, each named after its status" do
    render_picker("pending")
    SubjectProgress.statuses.each_key do |status|
      expect(page).to have_button(I18n.t("subject_progresses.statuses.#{status}"))
    end
  end

  it "sends the status with PATCH to the progress of the subject" do
    render_picker("pending")
    expect(page).to have_css("form[action='/subjects/#{subject_record.id}/progress'][method='post'] " \
                             "input[name='_method'][value='patch']", count: 5, visible: :all)
  end

  it "sends the status of each button" do
    render_picker("pending")
    expect(page).to have_css("form input[name='status'][value='in_progress']", visible: :all)
  end

  it "marks only the current status as pressed" do
    render_picker("regular")
    expect(page).to have_css("button[aria-pressed='true']", count: 1,
                                                            text: I18n.t("subject_progresses.statuses.regular"))
  end

  it "adds a check mark to the current status, so it is not only a color" do
    render_picker("regular")
    expect(page).to have_css("button[aria-pressed='true']", text: "✓")
  end

  it "marks nothing as pressed when there is no status, like for a visitor" do
    render_picker(nil)
    expect(page).to have_no_css("button[aria-pressed='true']")
  end

  describe "missing prerequisites" do
    let(:required) { build_stubbed(:subject, name: "Álgebra") }

    def render_with(status:, missing:)
      render_inline(described_class.new(subject: subject_record, status: status, missing: missing))
    end

    it "lists the missing prerequisites as links when the subject has no status yet" do
      render_with(status: "pending", missing: [required])
      expect(page).to have_css("[role='note'] a[href='/subjects/#{required.id}']", text: "Álgebra")
    end

    it "explains what is needed" do
      render_with(status: "pending", missing: [required])
      expect(page).to have_text(I18n.t("subject_progresses.picker.missing"))
    end

    it "says nothing when no prerequisite is missing" do
      render_with(status: "pending", missing: [])
      expect(page).to have_no_css("[role='note']")
    end

    it "says nothing once the subject has a status of its own" do
      render_with(status: "regular", missing: [required])
      expect(page).to have_no_css("[role='note']")
    end

    it "announces the missing prerequisites as an alert when the change was rejected" do
      render_inline(described_class.new(subject: subject_record, status: "regular", missing: [required],
                                        rejected: true))
      expect(page).to have_css("[role='alert']", text: "Álgebra")
    end
  end
end
