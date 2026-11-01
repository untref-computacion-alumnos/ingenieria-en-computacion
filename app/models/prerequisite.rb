# frozen_string_literal: true

class Prerequisite < ApplicationRecord
  belongs_to :subject
  belongs_to :required_subject, class_name: "Subject"
end
