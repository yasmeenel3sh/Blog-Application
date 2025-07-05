require 'rails_helper'

RSpec.describe "Api::V1::Comments" do
  let!(:tag) { Tag.create!(name: "rails") }
  let!(:user) do
    User.create!(
      name: "Commenter",
      email: "commenter@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end
  let!(:post_record) { Post.create!(title: "Post", body: "Body", user: user, tags: [ tag ]) }
  let!(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  describe "POST /comments" do
    context "create comment (happy)" do
      it "creates a comment and returns 201" do
        post "/api/v1/comments", params: {
          comment: {
            body: "Nice post",
            post_id: post_record.id
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:created)
      end
    end

    context "unauthenticated (unhappy)" do
      it "returns 401" do
        post "/api/v1/comments", params: {
          comment: {
            body: "No token",
            post_id: post_record.id
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "missing body (unhappy)" do
      it "returns 422" do
        post "/api/v1/comments", params: {
          comment: {
            body: "",
            post_id: post_record.id
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "Put /comments/:id" do
    let!(:comment) { Comment.create!(body: "Original", post: post_record, user: user) }

    context "update own comment (happy)" do
      it "updates and returns 200" do
        put "/api/v1/comments/#{comment.id}", params: {
          comment: {
            body: "Updated!"
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:ok)
      end
    end

    context "update another user's comment (unhappy)" do
      let!(:other_user) do
        User.create!(name: "Other", email: "other@example.com", password: "password", password_confirmation: "password")
      end
      let!(:other_comment) { Comment.create!(body: "Not yours", post: post_record, user: other_user) }

      it "returns 403 forbidden" do
        put "/api/v1/comments/#{other_comment.id}", params: {
          comment: {
            body: "Trying to edit"
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["error"]).to eq("Forbidden, you are not the owner")
      end
    end
  end

  describe "DELETE /comments/:id" do
    let!(:comment) { Comment.create!(body: "Delete me", post: post_record, user: user) }

    context "delete own comment (happy)" do
      it "returns 204" do
        delete "/api/v1/comments/#{comment.id}", headers: auth_headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "delete another user's comment (unhappy)" do
      let!(:other_user) do
        User.create!(name: "Other", email: "other@example.com", password: "password", password_confirmation: "password")
      end
      let!(:other_comment) { Comment.create!(body: "Not yours", post: post_record, user: other_user) }

      it "returns 403 forbidden" do
        delete "/api/v1/comments/#{other_comment.id}", headers: auth_headers
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["error"]).to eq("Forbidden, you are not the owner")
      end
    end
  end

  describe "handling non-existent comment ID (unhappy)" do
    let(:invalid_id) { 99999 } # unlikely to exist

    context "update non-existent comment (unhappy)" do
      it "returns 404 not found" do
        put "/api/v1/comments/#{invalid_id}", params: {
          comment: {
             body: "Updated"
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Comment not found")
      end
    end
    context "delete non-existent comment (unhappy)" do
      it "returns 404 not found" do
        delete "/api/v1/comments/#{invalid_id}", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Comment not found")
      end
    end
   end
end
