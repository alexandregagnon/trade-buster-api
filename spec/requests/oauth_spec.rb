# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OAuth", type: :request do
  before do
    @app = Doorkeeper::Application.create(
      name: "StashMobileApp",
      redirect_uri: "",
      uid: "stash-mobile-app",
      confidential: false
    )
  end

  describe "POST /oauth/token" do
    it "returns appropriate information" do
      user = create(:user, password: "TestTest12!")

      post oauth_token_path, params: {
        email: user.email,
        password: "TestTest12!",
        grant_type: "password",
        client_id: @app.uid
      }

      aggregate_failures "returns OK with all correct info" do
        expect(response).to have_http_status(:ok)
        expect(json["access_token"]).not_to be_nil
        expect(json["token_type"]).to eq("Bearer")
        expect(json["expires_in"]).not_to be_nil
        expect(json["refresh_token"]).not_to be_nil
        expect(json["created_at"]).not_to be_nil
      end
    end

    describe "Token operations" do
      let(:user) { create(:user, password: "TestTest12!") }

      let(:token_params) do
        {
          email: user.email,
          password: "TestTest12!",
          grant_type: "password",
          client_id: @app.uid
        }
      end

      let(:oauth_token) do
        post oauth_token_path, params: token_params
        json
      end

      let(:access_token) do
        token = oauth_token["access_token"]
        @json = nil
        token
      end

      let(:refresh_token) do
        token = oauth_token["refresh_token"]
        @json = nil
        token
      end

      it "returned token is usable" do
        user_collection = create(:collection, user_id: user.id)

        get collections_path(format: :json), headers: { Authorization: "Bearer #{access_token}" }
        aggregate_failures "returns OK and collections" do
          expect(response).to have_http_status(:ok)
          expect(json.length).to eq(1)
          expect(json[0]["name"]).to eq(user_collection.name)
        end
      end

      describe "#refresh_token" do
        it "can refresh the token" do
          post oauth_token_path(format: :json), params: {
            refresh_token: refresh_token,
            grant_type: "refresh_token",
            client_id: @app.uid
          }

          aggregate_failures "returns OK with all correct info" do
            expect(response).to have_http_status(:ok)
            expect(json["access_token"]).not_to be_nil
            expect(json["token_type"]).to eq("Bearer")
            expect(json["expires_in"]).not_to be_nil
            expect(json["refresh_token"]).not_to be_nil
            expect(json["created_at"]).not_to be_nil
          end
        end
      end

      describe "#revoke_token" do
        before do
          access_token
        end

        it "can revoke a token" do
          post oauth_revoke_path, params: {
            token: access_token,
            client_id: @app.uid
          }
          token = Doorkeeper::AccessToken.find_by(token: access_token)
          expect(response).to have_http_status(:ok)
          expect(token.revoked?).to be true
        end
      end
    end
  end
end
