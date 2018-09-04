require 'rails_helper'

describe 'the base API controller' do
  describe '#root' do
    context 'with an authenticated user' do
      let(:user) { create :user }

      before do
        get '/api', headers: auth_header(user)
      end

      it 'responds with a 200' do
        expect(response).to have_http_status :ok
      end
    end

    context 'with an unauthenticated user' do
      before do
        get '/api'
      end

      it 'responds with a 401' do
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
