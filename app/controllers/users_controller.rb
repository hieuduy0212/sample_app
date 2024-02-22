class UsersController < ApplicationController
  # action filter
  before_action :logged_in_user, except: %i(show create new)
  before_action :find_user, except: %i(index create new)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def show; end

  def index
    @pagy, @users = pagy User.order_by_name, items: Settings.page_10
  end

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

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".success"
    else
      flash[:failed] = t ".failed"
    end
    redirect_to users_path
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

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "shared.error_messages.please_log_in"
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:warning] = t "shared.error_messages.forbidden"
    redirect_to root_path
  end

  def admin_user
    return if current_user.admin?

    flash[:warning] = t "shared.error_messages.forbidden"
    redirect_to root_path
  end
end
