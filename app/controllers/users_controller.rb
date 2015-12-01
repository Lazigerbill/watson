class UsersController < ApplicationController
skip_before_filter :require_login, only: [:new, :create, :show]

def new
  @user = User.new
end

def create
  @user = User.new(user_params)
  if @user.save
    redirect_to login_path, :notice => "User #{@user.username} created!"
  else
    flash.now[:error] = @user.errors.full_messages.first 
    render :new
  end
end

def show
  @user = User.find(params[:id])
end

def edit
    @user = current_user
end

def update
  @user = current_user
  if @user.update_attributes(user_params)
    redirect_to entries_path, :flash => { :success => "User #{@user.username} updated!" }
  else
    @user.errors.full_messages.each do |msg|
      flash.now[:error] = msg
    end
    render :edit 
  end
  
end

def delete
  
end

private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
