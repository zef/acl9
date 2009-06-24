module Acl9
  def default_registry
    @@registry ||= Registry.new
  end

  module_function :default_registry

  class Registry
    class DoubleEntryError  < StandardError; end
    class UnknownController < StandardError; end

    def initialize
      @controllers = {}
    end

    def entry!(controller, &block)
      if @controllers.include?(controller.to_s)
        raise DoubleEntryError, "#{controller} has already registered an ACL"
      end

      (@controllers[controller.to_s] = Acl9::Dsl::Generators::GenericLambda.new).acl_block!(&block)
    end

    def allow?(subject, controller, action, variables = {})
      l = @controllers[controller.to_s] or raise UnknownController, controller.to_s

      l.call(subject, action.to_s, variables)
    end
  end
end
