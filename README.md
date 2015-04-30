# roda-action

A plugin for Roda to resolve actions from roda-container

## Installation

```ruby
gem 'roda-action', '0.0.1'
```

## Usage

```ruby
class MyApplication < Roda
  plugin :action
end

class UsersController
  attr_reader :repository

  def initialize(repository = {})
    @repository = repository
  end

  def index
    repository.values
  end

  def show(user_id)
    repository[user_id]
  end
end

MyApplication.register(:users_controller) do
  UsersController.new({
    '1' => { name: 'Jack' },
    '2' => { name: 'Gill' }
  })
end

route do |r|
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

## Contributing

1. Fork it ( https://github.com/AMHOL/roda-action )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT](LICENSE.txt)
