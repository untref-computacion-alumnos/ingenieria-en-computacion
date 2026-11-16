# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SubjectGrades" do
  describe "PATCH /subjects/:subject_id/grade" do
    let(:subject_record) { create(:subject) }
    let(:user) { create(:user, :with_study_plan) }
    let(:turbo_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    def save(attributes = {}, headers: {}, **fields)
      patch subject_grade_path(subject_record), params: { subject_progress: attributes.merge(fields) }, headers: headers
    end

    context "when nobody is signed in" do
      it "asks to log in" do
        save(grade: "8")
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user has not chosen a study plan" do
      before { sign_in create(:user) }

      it "sends them to the plan picker" do
        save(grade: "8")
        expect(response).to redirect_to(edit_users_study_plan_path)
      end
    end

    context "when the student approved the subject" do
      let!(:progress) { create(:subject_progress, user: user, subject: subject_record, status: :approved) }

      before { sign_in user }

      it "stores the grade" do
        expect { save(grade: "8") }.to change { progress.reload.grade }.from(nil).to(8)
      end

      it "stores a grade with a decimal" do
        expect { save(grade: "7.5") }.to change { progress.reload.grade }.from(nil).to(7.5)
      end

      it "stores the date" do
        expect { save(approved_on: "2024-12-10") }.to change { progress.reload.approved_on }.to(Date.new(2024, 12, 10))
      end

      it "stores both together and keeps the status" do
        save(grade: "8", approved_on: "2024-12-10")
        expect(progress.reload.status).to eq("approved")
      end

      it "can clear a grade that was saved before" do
        progress.update!(grade: 8)
        expect { save(grade: "") }.to change { progress.reload.grade }.from(8).to(nil)
      end

      it "redirects back to the subject" do
        save(grade: "8")
        expect(response).to redirect_to(subject_path(subject_record))
      end

      it "answers 303 so the browser follows with a GET" do
        save(grade: "8")
        expect(response).to have_http_status(:see_other)
      end

      it "confirms with a notice" do
        save(grade: "8")
        expect(flash[:notice]).to eq(I18n.t("subject_grades.form.saved"))
      end

      it "does not touch the progress of other users" do
        other = create(:subject_progress, subject: subject_record, status: :approved, grade: 6)
        save(grade: "8")
        expect(other.reload.grade).to eq(6)
      end

      it "ignores a status sent along with the grade" do
        save(grade: "8", status: "pending")
        expect(progress.reload.status).to eq("approved")
      end

      it "ignores the final exam flag for an approved subject" do
        save(grade: "8", final_exam_taken: "1")
        expect(progress.reload.final_exam_taken).to be(false)
      end
    end

    context "when the student promoted the subject" do
      let!(:progress) { create(:subject_progress, user: user, subject: subject_record, status: :promoted) }

      before { sign_in user }

      it "stores that the final exam was sat" do
        expect { save(final_exam_taken: "1") }.to change { progress.reload.final_exam_taken }.from(false).to(true)
      end
    end

    context "with values that cannot be stored" do
      let!(:progress) { create(:subject_progress, user: user, subject: subject_record, status: :approved) }

      before { sign_in user }

      it "rejects a grade above 10 and stores nothing" do
        expect { save(grade: "11") }.not_to(change { progress.reload.grade })
      end

      it "rejects a grade below 1" do
        expect { save(grade: "0") }.not_to(change { progress.reload.grade })
      end

      it "rejects a date in the future and stores nothing" do
        expect { save(approved_on: Date.current.next_day.iso8601) }.not_to(change { progress.reload.approved_on })
      end

      it "does not keep the valid hald when the other one is invalid" do
        save(grade: "8", approved_on: Date.current.next_day.iso8601)
        expect(progress.reload.grade).to be_nil
      end

      it "goes back to the subject with an alert about the grade" do
        save(grade: "11")
        expect(flash[:alert]).to include(
          I18n.t("activerecord.errors.models.subject_progress.attributes.grade.invalid_grade")
        )
      end

      it "goes back to the subject with an alert about the date" do
        save(approved_on: Date.current.next_day.iso8601)
        expect(flash[:alert]).to include(
          I18n.t("activerecord.errors.models.subject_progress.attributes.approved_on.future")
        )
      end

      it "redirects with 303 after a rejection too" do
        save(grade: "11")
        expect(response).to redirect_to(subject_path(subject_record))
      end
    end

    context "when the student has not approved the subject" do
      it "answers 404 when there is no progress at all" do
        sign_in user
        save(grade: "8")
        expect(response).to have_http_status(:not_found)
      end

      it "stores nothing for a subject that is only in progress" do
        create(:subject_progress, user: user, subject: subject_record, status: :regular)
        sign_in user
        expect { save(grade: "8") }.not_to change(SubjectProgress.where.not(grade: nil), :count)
      end
    end

    context "when Turbo asks for a stream" do
      let!(:progress) { create(:subject_progress, user: user, subject: subject_record, status: :approved) }
      let(:target) { "grade_form_subject_#{subject_record.id}" }

      before { sign_in user }

      it "answers 200, not a redirect" do
        save({ grade: "8" }, headers: turbo_headers)
        expect(response).to have_http_status(:ok)
      end

      it "answers with the Turbo Stream media type" do
        save({ grade: "8" }, headers: turbo_headers)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "still stores the grade" do
        expect { save({ grade: "8" }, headers: turbo_headers) }.to change { progress.reload.grade }.to(8)
      end

      it "replaces the form with the saved values and a confirmation" do
        save({ grade: "8" }, headers: turbo_headers)
        assert_select "turbo-stream[action='replace'][target='#{target}'] [role='status']"
      end

      it "answers 422 and shows the errors when the grade is invalid" do
        save({ grade: "11" }, headers: turbo_headers)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "replaces the form with the error alert when the grade is invalid" do
        save({ grade: "11" }, headers: turbo_headers)
        assert_select "turbo-stream[target='#{target}'] [role='alert']"
      end

      it "keeps what the student typed when it is rejected" do
        save({ grade: "11" }, headers: turbo_headers)
        assert_select "turbo-stream[target='#{target}'] input[name='subject_progress[grade]'][value='11']"
      end
    end
  end
end
