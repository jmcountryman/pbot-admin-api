require 'rails_helper'

describe 'the intro sounds controller' do
  let(:user) { create :user }

  describe '#create' do
    context 'when required params are missing' do
      before do
        post '/api/intro_sounds', headers: auth_header(user)
      end

      it 'responds with HTTP 400' do
        expect(response).to have_http_status :bad_request
      end
    end
  end
end
