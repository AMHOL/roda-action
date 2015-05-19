require 'spec_helper'

class Controller
  def index
    'It worked!!!'
  end

  def show(id)
    "Now showing #{id}"
  end
end

class ConcurrencyController
  def initialize(app)
    @app = app
  end

  def one
    'Request 1:' + @app.request.params.to_s
  end

  def two
    'Request 2:' + @app.request.params.to_s
  end
end

Roda.register(:controller) { Controller.new }
Roda.register(:concurrency_controller) { ConcurrencyController.new(Roda.instance.resolve(:app)) }

Roda.route do |r|
  Roda.instance.register(:app, self, call: false)

  r.on 'action' do
    r.is(&Roda.action(:controller, :index))

    r.on :id do |id|
      r.get(&Roda.action(:controller, :show).bind_arguments(id))
    end
  end

  r.on 'concurrency' do
    r.on 'one' do
      sleep(0.1)
      r.get(&Roda.action(:concurrency_controller, :one))
    end

    r.on 'two' do
      r.get(&Roda.action(:concurrency_controller, :two))
    end
  end
end

RSpec.describe 'action plugin' do
  it 'binds a controller method to the matched route' do
    get '/action', {}

    expect(last_response.body).to eq('It worked!!!')
  end

  it 'allows binding of arguments to action methods' do
    get '/action/1337', {}

    expect(last_response.body).to eq('Now showing 1337')
  end

  it 'is threadsafe' do
    threads = []
    queue = Queue.new
    threads << Thread.new { queue << get('/concurrency/one', one: true) }
    threads << Thread.new { queue << get('/concurrency/two', two: true) }
    threads.each(&:join)

    response_1 = queue.pop
    response_2 = queue.pop

    if response_1.body =~ /^Request 1\:/
      expect(response_1.body).to end_with("{\"one\"=>\"true\"}")
      expect(response_2.body).to end_with("{\"two\"=>\"true\"}")
    else
      expect(response_2.body).to end_with("{\"one\"=>\"true\"}")
      expect(response_1.body).to end_with("{\"two\"=>\"true\"}")
    end
  end
end
