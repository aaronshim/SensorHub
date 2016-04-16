class DiagsController < ApplicationController
  def test
    render text: 'Hello, world!'
  end

  def ping
    render text: 'pong'
  end

  def repeat
    render text: params.to_hash.to_json
  end
end
