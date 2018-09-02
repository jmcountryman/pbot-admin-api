class ApplicationController < ActionController::API
  def root
    render plain: 'It works!'
  end
end
