require 'roar/decorator'

module API
  module V3
    module WorkPackages
      class WorkPackageSumsRepresenter < ::API::Decorators::Single
        extend ::API::V3::Utilities::CustomFieldInjector::RepresenterClass
        include ActionView::Helpers::NumberHelper
        include ::API::Decorators::DateProperty

        custom_field_injector(injector_class: ::API::V3::Utilities::CustomFieldSumInjector)

        def initialize(sums, project)
          @project = project
          # breaking inheritance law here
          super(sums, current_user: nil)
        end

        def self.create(sums, current_user, project: nil)
          create_class(Schema::WorkPackageSumsSchema.new, current_user).new(sums, project)
        end

        property :estimated_time,
                 exec_context: :decorator,
                 getter: ->(*) {
                   datetime_formatter.format_duration_from_hours(represented.estimated_hours,
                                                                 allow_nil: true)
                 },
                 skip_render: ->(*) do
                  !User.current.allowed_to?(:view_estimated_time, @project)
                 end

        property :story_points,
                 render_nil: true

        property :remaining_time,
                 render_nil: true,
                 exec_context: :decorator,
                 getter: ->(*) {
                   datetime_formatter.format_duration_from_hours(represented.remaining_hours,
                                                                 allow_nil: true)
                 },
                 skip_render: ->(*) do
                  !User.current.allowed_to?(:view_remaining_time, @project)
                 end

        property :overall_costs,
                 exec_context: :decorator,
                 getter: ->(*) {
                   number_to_currency(represented.overall_costs)
                 }

        property :labor_costs,
                 exec_context: :decorator,
                 getter: ->(*) {
                   number_to_currency(represented.labor_costs)
                 }

        property :material_costs,
                 exec_context: :decorator,
                 getter: ->(*) {
                   number_to_currency(represented.material_costs)
                 }
      end
    end
  end
end
