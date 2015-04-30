require 'spec_helper'

module Test
  class Controller
    def index
      'It worked!!!'
    end
  end
end

Roda.register(:controller) { Test::Controller.new }
Roda.route do |r|
  r.root(&Roda.action(:controller, :index))
end

RSpec.describe 'action plugin' do
  it 'binds a controller method to the matched route' do
    get '/', {}

    expect(last_response.body).to eq('It worked!!!')
  end
end
