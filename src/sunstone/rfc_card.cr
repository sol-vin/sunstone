require "./rfc_card/core/models"
require "./rfc_card/core/renderer"
require "./rfc_card/dsl/suggestion_builder"
require "./rfc_card/dsl/council_builder"
require "./rfc_card/dsl/card_builder"

module Sunstone
  # Modular `rfc_card` slide component builder for Sunstone technical presentation decks.
  #
  # Provides Two-Tier Core Engine & Declarative DSL builders for rendering `[AS-X]`
  # architectural decision matrices, specialist council deliberations, and approval statuses:
  # - Tier 1 (`Core`): `RfcCardSpec`, `SuggestionItem`, `CouncilCommentSpec`, `Renderer`
  # - Tier 2 (`DSL`): `DSL::CardBuilder`, `DSL::SuggestionBuilder`, `DSL::CouncilCommentBuilder`
  module RfcCard
    # Builds an immutable `RfcCardSpec` via the declarative `DSL::CardBuilder`.
    def self.build(&block : DSL::CardBuilder -> Nil) : RfcCardSpec
      builder = DSL::CardBuilder.new
      yield builder
      builder.to_spec
    end

    # Renders an `RfcCardSpec` into zero-inline-style semantic HTML.
    def self.render(spec : RfcCardSpec = RfcCardSpec.new) : String
      Renderer.render_html(spec)
    end

    # Renders an `rfc_card` into zero-inline-style semantic HTML using the declarative `DSL::CardBuilder`.
    def self.render(&block : DSL::CardBuilder -> Nil) : String
      builder = DSL::CardBuilder.new
      yield builder
      builder.render
    end

    # Parses a `YAML::Any` node into a strongly-typed `RfcCardSpec`.
    def self.from_yaml(data : YAML::Any) : RfcCardSpec
      RfcCardSpec.from_yaml(data)
    end

    # Parses and renders a `YAML::Any` node into zero-inline-style semantic HTML.
    def self.render_yaml(data : YAML::Any) : String
      Renderer.render_html(RfcCardSpec.from_yaml(data))
    end

    # Renders speaker-reference Markdown for an `RfcCardSpec`.
    def self.render_markdown(spec : RfcCardSpec) : String
      Renderer.render_markdown(spec)
    end

    # Renders speaker-reference Markdown using the declarative `DSL::CardBuilder`.
    def self.render_markdown(&block : DSL::CardBuilder -> Nil) : String
      builder = DSL::CardBuilder.new
      yield builder
      builder.render_markdown
    end

    # Returns the semantic CSS stylesheet for `.rfc-card` and `.rfc-decision-matrix`.
    def self.stylesheet : String
      Renderer.render_css
    end
  end

  # Canonical alias exposing `Sunstone::RFCCard` alongside `Sunstone::RfcCard`.
  alias RFCCard = RfcCard

  # Top-level declarative `Sunstone.rfc_card` builder returning rendered semantic HTML.
  def self.rfc_card(&block : RfcCard::DSL::CardBuilder -> Nil) : String
    RfcCard.render(&block)
  end

  # Top-level `Sunstone.rfc_card` renderer for a pre-built `RfcCardSpec`.
  def self.rfc_card(spec : RfcCard::RfcCardSpec) : String
    RfcCard.render(spec)
  end

  # Top-level `Sunstone.rfc_card` renderer for a `YAML::Any` node.
  def self.rfc_card(data : YAML::Any) : String
    RfcCard.render_yaml(data)
  end

  # Top-level declarative builder returning the `RfcCard::RfcCardSpec` struct.
  def self.build_rfc_card(&block : RfcCard::DSL::CardBuilder -> Nil) : RfcCard::RfcCardSpec
    RfcCard.build(&block)
  end
end
