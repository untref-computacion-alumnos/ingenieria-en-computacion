# frozen_string_literal: true

ParameterType(
  name: "status",
  regexp: /pending|in progress|regular|approved|promoted|available|blocked/,
  transformer: lambda { |name|
    name.tr(" ", "_")
  }
)
