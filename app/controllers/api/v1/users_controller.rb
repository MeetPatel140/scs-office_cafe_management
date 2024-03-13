class Api::V1::UsersController < ApplicationController
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :phone)
  end

  def render_not_found
    render json: { error: "User not found" }, status: :not_found
  end

  def render_unprocessable_entity
    render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
  end

  def render_invalid
    render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
  end

  def render_created
    render json: @user
  end

  def render_updated
    render json: @user
  end

  def render_deleted
    render json: @user
  end
end
