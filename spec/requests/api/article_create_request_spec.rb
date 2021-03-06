# frozen_string_literal: true

RSpec.describe 'Api::Articles :create', type: :request do
  let(:user) { create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  describe 'not logged in user cannot create an article' do
    before do
      post '/api/articles', params: { title: 'A title', body: 'The body' }
    end

    it 'has a 401 response' do
      expect(response).to have_http_status 401
    end

    it 'responds with error message' do
      expect(response_json['errors']).to eq ["You need to sign in or sign up before continuing."]
    end
  end

  describe 'Journalist can successfully post an article' do
    before do
      post '/api/articles', headers: headers, params: { title: 'A title', body: 'The body' }
    end

    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end

    it 'responds with article :id' do
      expect(response_json).to have_key 'id'
    end

    it 'responds with success message' do
      expect(response_json['message']).to eq 'Article successfully created!'
    end
  end

  describe 'Journalist cannot post an article when' do
    describe 'title is missing' do
      before do
        post '/api/articles', headers: headers, params: { body: 'The body' }
      end

      it 'has a 400 response' do
        expect(response).to have_http_status 400
      end

      it 'has a descriptive error message' do
        expect(response_json['message']).to eq "Title can't be blank"
      end
    end

    describe 'body is missing' do
      before do
        post '/api/articles', headers: headers, params: { title: 'A title' }
      end

      it 'has a 400 response' do
        expect(response).to have_http_status 400
      end

      it 'has a descriptive error message' do
        expect(response_json['message']).to eq "Body can't be blank"
      end
    end
  end
end
