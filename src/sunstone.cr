require "opal"
{% if @top_level.has_constant?(:Carbon) || flag?(:has_carbon) %}
  require "carbon"
{% end %}
require "./sunstone/version"
require "./sunstone/models/deck"
require "./sunstone/models/slide"
require "./sunstone/models/palette"
require "./sunstone/chart"
require "./sunstone/layouts/router"
require "./sunstone/generator"
require "./sunstone/landing_page"
require "./sunstone/server"
require "./sunstone/scaffold"
require "./sunstone/cli"

module Sunstone
  # If Carbon is available in the environment, declare version via Carbon DSL
  {% begin %}
    {% if @top_level.has_constant?(:Carbon) %}
      Carbon.version!
    {% end %}
  {% end %}
end

Sunstone::CLI.run(ARGV)
