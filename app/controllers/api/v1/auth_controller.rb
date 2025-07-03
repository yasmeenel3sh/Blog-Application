class Api::V1::AuthController < ApplicationController
  skip_before_action :authorize_request, only: [ :signup, :login ]

  # POST /signup
  def signup
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          image: user.image
       }
     }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          image: user.image
       }
     }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :image)
  end
end
