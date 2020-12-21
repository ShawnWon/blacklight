# frozen_string_literal: true

module Blacklight
  module Response
    # Render spellcheck results for a search query
    class SpellcheckComponent < ViewComponent::Base
      # @param [Blacklight::Response] response
      # @param [Array<String>] options explicit spellcheck options to render
      def initialize(response:, options: nil)
        @response = response
        @options = options || @response&.spelling&.words
      end

      def link_to_query(query)
        Deprecation.silence(Blacklight::UrlHelperBehavior) do
          @view_context.link_to_query(query)
        end
      end

      def render?
        Array(@options).any? && show_spellcheck_suggestions?(@response)
      end

      # @!group Search result helpers
      ##
      # Determine whether to display spellcheck suggestions
      #
      # @param [Blacklight::Solr::Response] response
      # @return [Boolean]
      def show_spellcheck_suggestions? response
        # The spelling response field may be missing from non solr repositories.
        response.total <= helpers.blacklight_config.spell_max &&
          !response.spelling.nil? &&
          response.spelling.words.any?
      end
    end
  end
end