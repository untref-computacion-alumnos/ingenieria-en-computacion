# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SubjectProgresses" do
  describe "PATCH /subjects/:subject_id/progress" do
    let(:subject_record) { create(:subject) }
    let(:user) { create(:user, :with_study_plan) }

    def mark(status, subject: subject_record)
      patch subject_progress_path(subject), params: { status: status }
    end

    context "when nobody is signed in" do
      it "asks to log in" do
        mark("approved")
        expect(response).to redirect_to(new_user_session_path)
      end

      it "stores nothing" do
        expect { mark("approved") }.not_to change(SubjectProgress, :count)
      end
    end

    context "when the user has not chosen a study plan" do
      before { sign_in create(:user) }

      it "sends them to the plan picker" do
        mark("approved")
        expect(response).to redirect_to(edit_users_study_plan_path)
      end

      it "stores nothing" do
        expect { mark("approved") }.not_to change(SubjectProgress, :count)
      end
    end

    context "when a user follows a plan" do
      before { sign_in user }

      it "stores the status for that user and subject" do
        expect { mark("in_progress") }.to change { user.status_for(subject_record) }.from("pending").to("in_progress")
      end

      it "creates one row the first time" do
        expect { mark("regular") }.to change(SubjectProgress, :count).by(1)
      end

      it "redirects back to the subject" do
        mark("regular")
        expect(response).to redirect_to(subject_path(subject_record))
      end

      it "answers 303 so the browser follows with a GET" do
        mark("regular")
        expect(response).to have_http_status(:see_other)
      end

      it "changes an existing status" do
        create(:subject_progress, user: user, subject: subject_record, status: :regular)
        expect { mark("approved") }.to change { user.status_for(subject_record) }.from("regular").to("approved")
      end

      it "does not create another row when the status changes" do
        create(:subject_progress, user: user, subject: subject_record, status: :regular)
        expect { mark("approved") }.not_to change(SubjectProgress, :count)
      end

      it "can go back to pending" do
        create(:subject_progress, user: user, subject: subject_record, status: :approved)
        expect { mark("pending") }.to change { user.status_for(subject_record) }.from("approved").to("pending")
      end

      it "does not touch the progress of other users" do
        other = create(:subject_progress, subject: subject_record, status: :promoted)
        mark("approved")
        expect(other.reload.status).to eq("promoted")
      end

      it "does not touch the progress of other subjects" do
        other = create(:subject_progress, user: user, status: :promoted)
        mark("approved")
        expect(other.reload.status).to eq("promoted")
      end
    end

    context "with a status that cannot be stored" do
      before { sign_in user }

      it "answers 422 for an unknown status" do
        mark("free")
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "answers 422 when no status is sent" do
        patch subject_progress_path(subject_record)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "answers 422 when the status is not a plain value" do
        patch subject_progress_path(subject_record), params: { status: %w[approved regular] }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not change an existing status" do
        create(:subject_progress, user: user, subject: subject_record, status: :regular)
        expect { mark("free") }.not_to(change { user.status_for(subject_record) })
      end
    end

    context "with a subject that does not exist" do
      before { sign_in user }

      it "answers not found" do
        patch subject_progress_path(subject_id: 0), params: { status: "approved" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when Turbo asks for a stream" do
      let(:turbo_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

      def mark_with_turbo(status)
        patch subject_progress_path(subject_record), params: { status: status }, headers: turbo_headers
      end

      before { sign_in user }

      it "answers 200, not a redirect" do
        mark_with_turbo("approved")
        expect(response).to have_http_status(:ok)
      end

      it "answers with the Turbo Stream media type" do
        mark_with_turbo("approved")
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "still stores the status" do
        expect { mark_with_turbo("approved") }.to change { user.status_for(subject_record) }.to("approved")
      end

      it "replaces the badge of the card" do
        mark_with_turbo("approved")
        assert_select "turbo-stream[action='replace'][target='status_subject_#{subject_record.id}']"
        expect(response.body).to include("data-status=\"approved\"")
      end

      it "replaces the picker of the panel" do
        mark_with_turbo("approved")
        assert_select "turbo-stream[action='replace'][target='status_picker_subject_#{subject_record.id}']"
        expect(response.body).to include("aria-pressed=\"true\"")
      end

      it "answers 422 for a status that cannot be stored" do
        mark_with_turbo("free")
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "replaces the badge of a subject that this one unlocks" do
        unlocked = create(:subject, study_plan: subject_record.study_plan)
        create(:prerequisite, subject: unlocked, required_subject: subject_record)
        mark_with_turbo("regular")
        assert_select "turbo-stream[action='replace'][target='status_subject_#{unlocked.id}'] [data-status='available']"
      end

      it "shows a subject that goes back to pending as available when nothing blocks it" do
        create(:subject_progress, user: user, subject: subject_record, status: :approved)
        mark_with_turbo("pending")
        assert_select "turbo-stream[target='status_subject_#{subject_record.id}'] [data-status='available']"
      end

      it "does not touch the badges of unrelated subjects" do
        other = create(:subject, study_plan: subject_record.study_plan)
        mark_with_turbo("regular")
        assert_select "turbo-stream[target='status_subject_#{other.id}']", count: 0
      end
    end

    context "when a prerequisite is missing" do
      let(:required) { create(:subject, study_plan: subject_record.study_plan) }
      let(:turbo_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

      before do
        create(:prerequisite, subject: subject_record, required_subject: required)
        sign_in user
      end

      it "does not store the status" do
        expect { mark("in_progress") }.not_to change(SubjectProgress, :count)
      end

      it "sends the user back to the subject" do
        mark("in_progress")
        expect(response).to redirect_to(subject_path(subject_record))
      end

      it "tells why with a flash alert" do
        mark("in_progress")
        expect(flash[:alert]).to eq(I18n.t("subject_progresses.update.blocked"))
      end

      it "answers 422 to a Turbo request" do
        patch subject_progress_path(subject_record), params: { status: "in_progress" }, headers: turbo_headers
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "replaces the picker, with the missing prerequisites as an alert, for a Turbo request" do
        patch subject_progress_path(subject_record), params: { status: "in_progress" }, headers: turbo_headers
        assert_select "turbo-stream[action='replace'][target='status_picker_subject_#{subject_record.id}'] " \
                      "[role='alert'] a", text: required.name
      end

      it "still lets the user mark another status" do
        expect { mark("regular") }.to change(SubjectProgress, :count).by(1)
      end

      it "lets the user start it once the prerequisite is passed" do
        create(:subject_progress, user: user, subject: required, status: :regular)
        expect { mark("in_progress") }.to change { user.status_for(subject_record) }.from("pending").to("in_progress")
      end
    end

    context "when a visitor asks for a stream" do
      it "still redirects to the login page" do
        patch subject_progress_path(subject_record), params: { status: "approved" },
                                                     headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
