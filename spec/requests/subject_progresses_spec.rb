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
  end
end
