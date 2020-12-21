# frozen_string_literal: true
module Blacklight::FacetsHelperBehavior
  extend Deprecation
  self.deprecation_horizon = 'blacklight 8.0'

  include Blacklight::Facet

  ##
  # Renders a single section for facet limit with a specified
  # solr field used for faceting. Can be over-ridden for custom
  # display on a per-facet basis.
  #
  # @param [Blacklight::Solr::Response::Facets::FacetField] display_facet
  # @param [Boolean] :layout partial layout to render
  # @return [String]
  def render_facet_limit(display_facet, layout: true)
    field_config = facet_configuration_for_field(display_facet.name)
    return unless should_render_field?(field_config, display_facet)

    component = field_config.component.presence || Blacklight::FacetFieldListComponent
    if component == true
      Deprecation.warn(self, "It is no longer necessary to provide component=true. This will be an error in Blacklight 9")
      component = Blacklight::FacetFieldListComponent
    end

    render(
      component.new(
        facet_field: facet_field_presenter(field_config, display_facet),
        layout: (params[:action] == 'facet' ? false : layout)
      )
    )
  end

  ##
  # Determine whether a facet should be rendered as collapsed or not.
  #   - if the facet is 'active', don't collapse
  #   - if the facet is configured to collapse (the default), collapse
  #   - if the facet is configured not to collapse, don't collapse
  #
  # @deprecated
  # @param [Blacklight::Configuration::FacetField] facet_field
  # @return [Boolean]
  def should_collapse_facet? facet_field
    Deprecation.silence(Blacklight::FacetsHelperBehavior) do
      !facet_field_in_params?(facet_field.key) && facet_field.collapse
    end
  end
  deprecation_deprecate :should_collapse_facet?

  ##
  # The name of the partial to use to render a facet field.
  # uses the value of the "partial" field if set in the facet configuration
  # otherwise uses "facet_pivot" if this facet is a pivot facet
  # defaults to 'facet_limit'
  #
  # @return [String]
  def facet_partial_name(display_facet = nil)
    config = facet_configuration_for_field(display_facet.name)
    name = config.try(:partial)
    name ||= "facet_pivot" if config.pivot
    name || "facet_limit"
  end
  deprecation_deprecate :facet_partial_name

  def facet_field_presenter(facet_config, display_facet)
    (facet_config.presenter || Blacklight::FacetFieldPresenter).new(facet_config, display_facet, self)
  end

  ##
  # Where should this facet link to?
  #
  # @deprecated
  # @param [Blacklight::Solr::Response::Facets::FacetField] facet_field
  # @param [String] item
  # @return [String]
  def path_for_facet(facet_field, item, path_options = {})
    facet_config = facet_configuration_for_field(facet_field)
    facet_item_presenter(facet_config, item, facet_field).href(path_options)
  end
  deprecation_deprecate :path_for_facet

  ##
  # Are any facet restrictions for a field in the query parameters?
  # @private
  # @param [String] field
  # @return [Boolean]
  def facet_field_in_params? field
    config = facet_configuration_for_field(field)

    Deprecation.silence(Blacklight::SearchState) do
      search_state.has_facet? config
    end
  end
  # Left undeprecated for the sake of temporary backwards compatibility
  # deprecation_deprecate :facet_field_in_params?

  ##
  # Get the values of the facet set in the blacklight query string
  # @deprecated
  def facet_params field
    config = facet_configuration_for_field(field)

    search_state.params.dig(:f, config.key)
  end
  deprecation_deprecate :facet_params

  ##
  # Get the displayable version of a facet's value
  #
  # @param [Object] field
  # @param [String] item value
  # @return [String]
  # @deprecated
  def facet_display_value field, item
    deprecated_method(:facet_display_value)
    facet_config = facet_configuration_for_field(field)
    facet_item_presenter(facet_config, item, field).label
  end

  # @deprecated
  def facet_field_id facet_field
    "facet-#{facet_field.key.parameterize}"
  end
  deprecation_deprecate :facet_field_id

  private

  def facet_value_for_facet_item item
    if item.respond_to? :value
      item.value
    else
      item
    end
  end

  def facet_item_presenter(facet_config, facet_item, facet_field)
    Blacklight::FacetItemPresenter.new(facet_item, facet_config, self, facet_field)
  end

  # We can't use .deprecation_deprecate here, because the new components need to
  # see the originally defined location for these methods in order to properly
  # call back into the helpers for backwards compatibility
  def deprecated_method(method_name)
    Deprecation.warn(Blacklight::FacetsHelperBehavior,
                     Deprecation.deprecated_method_warning(Blacklight::FacetsHelperBehavior,
                                                           method_name, {}),
                     caller)
  end
end
