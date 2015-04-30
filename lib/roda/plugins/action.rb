class Roda
  module RodaPlugins
    # The action plugin loads the container plugin and adds
    # the "action" class method to your Roda application.
    #
    # You can then register your controllers with the
    # app container and resolve a method on your controller
    # to pass as the matcher block.
    #
    # Example:
    #
    #   plugin :action
    #
    #   class UsersController
    #     attr_reader :repository
    #
    #     def initialize(repository = {})
    #       @repository = repository
    #     end
    #
    #     def index
    #       repository.values
    #     end
    #
    #     def show(user_id)
    #       repository[user_id]
    #     end
    #   end
    #
    #   MyApplication.register(:users_controller) do
    #     UsersController.new({
    #       '1' => { name: 'Jack' },
    #       '2' => { name: 'Gill' }
    #     })
    #   end
    #
    #   route do |r|
    #     r.on 'users' do
    #       r.is do
    #         r.get(&MyApplication.action(:users_controller, :index))
    #       end
    #
    #       r.is :id do |id|
    #         r.get(&MyApplication.action(:users_controller, :show).bind_arguments(id))
    #       end
    #     end
    #   end
    module Action
      # Action wrapper - allows binding of arguments that are already
      # loaded in parent matchers.
      class Action
        def initialize(action)
          @action = action.to_proc
        end

        def bind_arguments(*bindings)
          method = @action
          action = proc { |*args| method.call(*(bindings + args)) }
          @action = action
        end

        def to_proc
          @action
        end
      end

      # Load the container plugin, since the action plugin
      # depends on it.
      def self.load_dependencies(app, _opts = nil)
        app.plugin :container
      end

      module ClassMethods
        def action(controller_key, action)
          Action.new(resolve(controller_key).method(action))
        end
      end
    end

    register_plugin(:action, Action)
  end
end
