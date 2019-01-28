class ApplicationController < ActionController::API
  include Knock::Authenticable

  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def bad_request(exception)
    render plain: exception.message, status: :bad_request
  end
end
