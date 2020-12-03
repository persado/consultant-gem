# frozen_string_literal: true

module Benchmarking
  module AggregateTests
    class ControllerTest < Base
      def render(**args)
        ApplicationController.render(args)
      end

      def params
        ActionController::Parameters.new(
          { @model.class.name.downcase => @model.to_h },
        )
      end

      # Below, define/stub out any methods shared between controllers in your application

      def current_user
        relation = User.where(role: :content_admin)
        random_offset = rand(relation.length - 1)
        relation.offset(random_offset).first
      end

      def permitted_params
        if @permitted_params.nil? || params_stale?
          @permitted_params = PermittedParams.new(params, current_user)
        else
          @permitted_params
        end
      end

      private

      def params_stale?
        cached_id != @model.id
      end

      def cached_id
        @permitted_params.send(@model.class.name.downcase.to_sym)['id']
      end
    end
  end
end
