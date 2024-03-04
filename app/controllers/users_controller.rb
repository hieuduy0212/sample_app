class UsersController < ApplicationController
  # action filter
  before_action :logged_in_user, except: %i(show create new)
  before_action :find_user, except: %i(index create new)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def show
    @pagy, @microposts = pagy @user.feed, items: Settings.page_5
  end

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
      @user.send_mail_activate
      flash[:info] = t ".success"
      redirect_to root_path
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

  def following
    @title = t ".title"
    @pagy, @users = pagy @user.following, items: Settings.page_10
    render :show_follow
  end

  def followers
    @title = t ".title"
    @pagy, @users = pagy @user.followers, items: Settings.page_10
    render :show_follow
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
