class Api::V1::UsersController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:index, :show, :create]
  before_action :doorkeeper_authorize!, except: [:login, :logout]
  skip_before_action :verify_authenticity_token

  def index
    @users = User.all
    render json: { users: @users, message: "You have Succesfully Tested and Setup the Rails Public API" }, status: :ok
  end

  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user
    else
      render json: @user.errors
    end
  end

  def login
    user = User.find_by(email: params[:user][:email])
    if user&.valid_password?(params[:user][:password])
      client_app = Doorkeeper::Application.find_by(uid: params[:client_id])
      access_token = Doorkeeper::AccessToken.create!(
        resource_owner_id: user.id,
        application_id: client_app.id,
        refresh_token: generate_refresh_token, # Implement generate_refresh_token method
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        scopes: ''
      )
      render json: { user: user, access_token: access_token.token, message: 'Login successful' }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    if params[:access_token].present?
      current_token = Doorkeeper::AccessToken.find_by(token: params[:access_token])
      if current_token
        destroyed = current_token.destroy
        if destroyed
          render json: { message: 'Logout successful' }, status: :ok
        else
          render json: { error: 'Failed to destroy access token' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Invalid access token' }, status: :unauthorized
      end
    else
      render json: { error: 'Access token not provided' }, status: :unauthorized
    end
  end


  def logout1
    current_token = doorkeeper_token
    current_token.revoke if current_token.present?
    render json: { message: 'Logout successful' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :phone)
  end

  def generate_refresh_token
    SecureRandom.hex(32)
  end

end
