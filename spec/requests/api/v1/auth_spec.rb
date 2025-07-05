require 'rails_helper'

RSpec.describe "Api::V1::Auths", type: :request do
  describe "POST /signup" do
    it "creates a user and returns a token (happy)" do
      post "/api/v1/signup", params: {
        user: {
          name: "Yasmeen",
          email: "yasmeen@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("token")
    end

    it "fails when password and confirmation don't match (unhappy)" do
      post "/api/v1/signup", params: {
        user: {
          name: "Mismatch",
          email: "mismatch@example.com",
          password: "password",
          password_confirmation: "notpassword"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Password confirmation doesn't match Password")
    end

    it "fails when email is already taken (unhappy)" do
      User.create!(name: "Test", email: "test@example.com", password: "password", password_confirmation: "password")

      post "/api/v1/signup", params: {
        user: {
          name: "Duplicate",
          email: "test@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Email has already been taken")
    end
  end

  describe "POST /login" do
    let!(:user) { User.create!(name: "Login", email: "login@example.com", password: "password", password_confirmation: "password") }

    it "returns a token with valid credentials (happy)" do
      post "/api/v1/login", params: {
        email: "login@example.com",
        password: "password"
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("token")
    end

    it "fails with invalid password (unhappy)" do
      post "/api/v1/login", params: {
        email: "login@example.com",
        password: "wrongpassword"
      }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
    end

    it "fails with non-existent email (unhappy)" do
      post "/api/v1/login", params: {
        email: "notfound@example.com",
        password: "password"
      }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
    end
  end
end
