class ApplicationController < ActionController::API
  include Knock::Authenticable

  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  private

  def bad_request(exception)
    render plain: exception.message, status: :bad_request
  end

  def not_found
    render plain: 'Not found', status: :not_found
  end
end
