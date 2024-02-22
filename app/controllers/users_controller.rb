class UsersController < ApplicationController
  # action filter
  before_action :find_user, only: %i(show)
  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      reset_session
      flash[:success] = t ".success"
      log_in @user
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password,
                                 :password_confirmation
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "shared.error_messages.not_found_user"
    redirect_to root_path
  end
end
