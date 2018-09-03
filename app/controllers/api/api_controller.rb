module Api
  class ApiController < ApplicationController
    def root
      head :ok
    end
  end
end
