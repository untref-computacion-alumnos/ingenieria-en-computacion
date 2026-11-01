# frozen_string_literal: true

class Career < ApplicationRecord
  validates :name, presence: true
end
