class UsersController < ApplicationController
skip_before_filter :require_login, only: [:new, :create, :show]

def new
  @user = User.new
end

def create
  @user = User.new(user_params)
  if @user.save
    auto_login(@user)
    redirect_to(entries_path, notice: 'User was successfully created')
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
    redirect_to entries_path, :flash => { :success => "User profile updated!" }
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
    params.require(:user).permit(:first_name, :last_name, :student_id, :email, :password, :password_confirmation)
  end
end
