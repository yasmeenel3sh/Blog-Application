require 'rails_helper'

RSpec.describe "Api::V1::Posts" do
  # create tag before each test
  let!(:tag) { Tag.create!(name: "rails") }

  let!(:user) do
    User.create!(
      name: "Poster",
      email: "poster@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  let!(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  describe "POST /posts" do
    context "user creates a post with valid data (happy)" do
      it "creates a post and returns 201" do
        post "/api/v1/posts", params: {
          post: {
            title: "My Post",
            body: "Some content here",
            tag_ids: [ tag.id ]
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["title"]).to eq("My Post")
      end
    end

    context "unauthenticated user (unhappy)" do
      it "returns 401 unauthorized" do
        post "/api/v1/posts", params: {
          post: {
            title: "No Auth",
            body: "Missing token",
            tag_ids: [ tag.id ]
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "missing or empty tags (unhappy)" do
      it "returns 422 unprocessable entity" do
        post "/api/v1/posts", params: {
          post: {
            title: "Missing Tags",
            body: "No tags provided"
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Tags must have at least one tag")
      end


      it "fails when tags are present but empty (unhappy)" do
        post "/api/v1/posts",  params: {
            post: {
              title: "Title with no tags",
              body: "This should fail",
              tag_ids: []  # Explicitly empty
            }
          }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Tags must have at least one tag")
      end
    end

    context "missing/blank title/body" do
      it "returns 422 when title and body are blank" do
        post "/api/v1/posts", params: {
          post: {
            title: "",
            body: "",
            tag_ids: [ tag.id ]
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when title blank" do
        post "/api/v1/posts", params: {
          post: {
            title: "",
            body: "Not Blank",
            tag_ids: [ tag.id ]
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when title is missing" do
        post "/api/v1/posts", params: {
          post: {
            body: "Not Missing",
            tag_ids: [ tag.id ]
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end


      it "returns 422 when title is missing" do
        post "/api/v1/posts", params: {
          post: {
            title: "Not Missing",
            tag_ids: [ tag.id ]
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /posts" do
    before do
      Post.create!(title: "First", body: "Body", user: user, tags: [ tag ])
    end

    context "fetch posts with auth (happy)" do
      it "returns a list of posts" do
        get "/api/v1/posts", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to be >= 1
      end
    end

    context "unauthenticated access to posts (unhappy)" do
      it "returns 401 unauthorized" do
        get "/api/v1/posts"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /posts/:id" do
    let!(:post_record) { Post.create!(title: "Old", body: "Old body", user: user, tags: [ tag ]) }

    context "unauthenticated update (unhappy)" do
      it "returns 401 unauthorized" do
        put "/api/v1/posts/#{post_record.id}", params: {
          post: {
            title: "New Title",
            body: "Updated body"
          }
        }
        expect(response).to have_http_status(:unauthorized)
      end
    end


    context "update own post (happy)" do
      it "updates title and body" do
        put "/api/v1/posts/#{post_record.id}", params: {
          post: {
            title: "New Title",
            body: "Updated body"
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["title"]).to eq("New Title")
      end
    end



    context "update another user's post (unhappy)" do
      let!(:other_user) do
        User.create!(
          name: "Other",
          email: "other@example.com",
          password: "password",
          password_confirmation: "password"
        )
      end

      let!(:other_post) { Post.create!(title: "Other's", body: "Not yours", user: other_user, tags: [ tag ]) }

      it "returns 403 forbidden" do
        put "/api/v1/posts/#{other_post.id}", params: {
          post: {
            title: "Should not work"
          }
        }, headers: auth_headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["error"]).to eq("Forbidden, you are not the owner")
      end
    end
  end

  describe "DELETE /posts/:id" do
    let!(:post_record) { Post.create!(title: "To Delete", body: "Bye", user: user, tags: [ tag ]) }


    context "unauthenticated delete (unhappy)" do
      it "returns 401 unauthorized" do
        delete "/api/v1/posts/#{post_record.id}", params: {
          post: {
            title: "New Title",
            body: "Updated body"
          }
        }
        expect(response).to have_http_status(:unauthorized)
      end
    end


    context "delete own post (happy)" do
      it "returns 204 no content" do
        delete "/api/v1/posts/#{post_record.id}", headers: auth_headers

        expect(response).to have_http_status(:no_content)
      end
    end

    context "delete another user's post (unhappy)" do
      let!(:other_user) do
        User.create!(
          name: "Other",
          email: "other@example.com",
          password: "password",
          password_confirmation: "password"
        )
      end

      let!(:other_post) { Post.create!(title: "Other's", body: "Can't touch this", user: other_user, tags: [ tag ]) }

      it "returns 403 forbidden" do
        delete "/api/v1/posts/#{other_post.id}", headers: auth_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "handling non-existent post ID (unhappy)" do
    let(:invalid_id) { 99999 } # unlikely to exist

    it "returns 404 for GET /posts/:id" do
      get "/api/v1/posts/#{invalid_id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Post not found")
    end

    it "returns 404 for PUT /posts/:id" do
      put "/api/v1/posts/#{invalid_id}", params: {
        post: {
          title: "Doesn't Matter",
          body: "Won't Work"
        }
      }, headers: auth_headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Post not found")
    end

    it "returns 404 for DELETE /posts/:id" do
      delete "/api/v1/posts/#{invalid_id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Post not found")
    end
end
end
