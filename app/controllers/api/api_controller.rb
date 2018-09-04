module Api
  class ApiController < ApplicationController
    before_action :authenticate_user

    def root
      head :ok
    end
  end
end
