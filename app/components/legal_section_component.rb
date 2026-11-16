# frozen_string_literal: true

class LegalSectionComponent < ViewComponent::Base
  def initialize(id:, title:)
    super()
    @id = id
    @title = title
  end

  private

  attr_reader :id, :title
end
