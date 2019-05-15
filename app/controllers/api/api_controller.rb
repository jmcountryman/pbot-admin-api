module Api
  class ApiController < ApplicationController
    before_action :authenticate_user, except: :root

    def root
      head :ok
    end
  end
end
