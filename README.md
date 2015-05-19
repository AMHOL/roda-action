# roda-action

A plugin for Roda to resolve actions from roda-container

## Installation

```ruby
gem 'roda-action', '0.0.2'
```

## Usage

```ruby
class MyApplication < Roda
  plugin :json
  plugin :action
end

class UsersController
  attr_reader :repository

  def initialize(repository = [])
    @repository = repository
  end

  def index
    repository
  end

  def show(user_id)
    repository[user_id.to_i - 1]
  end
end

MyApplication.register(:users_controller) do
  UsersController.new([
    { name: 'Jack' },
    { name: 'Gill' }
  ])
end

MyApplication.route do |r|
  r.on 'users' do
    r.is do
      r.get(&MyApplication.action(:users_controller, :index))
    end

    r.is :id do |id|
      r.get(&MyApplication.action(:users_controller, :show).bind_arguments(id))
    end
  end
end
```

If you wish to have access to the usual Roda application instance methods in your registered controllers, it is recommended that you register the application and resolve it for use in your controllers:

```ruby
class MyApplication < Roda
  plugin :json
  plugin :action
end

class UsersController
  attr_reader :app, :repository

  def initialize(app, repository = [])
    @app, @repository = app, repository
  end

  def index
    repository
  end

  def show(user_id)
    repository[user_id.to_i - 1]
  end

  def create
    id = repository.length.next

    if (name = app.request.params['name'].to_s).length > 0
      repository << { name: name }
      app.response.redirect "/users/#{id}"
    end
  end
end

MyApplication.register(:users_repository, [
  { name: 'Jack' },
  { name: 'Gill' }
])

MyApplication.register(:users_controller) do
  UsersController.new(MyApplication.instance.resolve(:app), MyApplication.resolve(:users_repository))
end

MyApplication.route do |r|
  MyApplication.instance.register(:app, self, call: false)

  r.on 'users' do
    r.is do
      r.get(&MyApplication.action(:users_controller, :index))
      r.post(&MyApplication.action(:users_controller, :create))
    end

    r.is :id do |id|
      r.get(&MyApplication.action(:users_controller, :show).bind_arguments(id))
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/AMHOL/roda-action )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT](LICENSE.txt)
