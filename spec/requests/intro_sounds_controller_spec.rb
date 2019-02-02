require 'rails_helper'

describe 'the intro sounds controller' do
  let(:user) { create :user }

  let(:guild_id) { 1 }
  let(:target_user_id) { 1234 }
  let(:audio_file) { fixture_file_upload('intro_sounds/welcome_chris.mp3') }

  describe '#create' do
    context 'when required params are missing' do
      before do
        post '/api/intro_sounds', headers: auth_header(user)
      end

      it 'responds with HTTP 400' do
        expect(response).to have_http_status :bad_request
      end
    end

    context 'when required params are present' do
      before do
        post(
          '/api/intro_sounds',
          params: {guild: guild_id, user: target_user_id, file: audio_file},
          headers: auth_header(user)
        )
      end

      it 'responds with HTTP 200' do
        expect(response).to have_http_status :ok
      end

      it 'responds with the created object' do
        expect(JSON.parse(response.body)['id']).to be_present
      end
    end
  end

  # TODO: tests for index, update, destroy
end
