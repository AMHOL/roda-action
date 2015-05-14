require 'spec_helper'

class Controller
  def index
    'It worked!!!'
  end

  def show(id)
    "Now showing #{id}"
  end
end

Roda.register(:controller) { Controller.new }
Roda.route do |r|
  r.root(&Roda.action(:controller, :index))

  r.on :id do |id|
    r.get(&Roda.action(:controller, :show).bind_arguments(id))
  end
end

RSpec.describe 'action plugin' do
  it 'binds a controller method to the matched route' do
    get '/', {}

    expect(last_response.body).to eq('It worked!!!')
  end

  it 'allows binding of arguments to action methods' do
    get '/1337', {}

    expect(last_response.body).to eq('Now showing 1337')
  end
end
