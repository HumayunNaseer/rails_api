class Api::V1::SessionsController < Devise::SessionsController
  before_action :sign_in_params, only: :create
  before_action :load_user, only: :create
  before_action :valid_token, only: :destroy
  skip_before_action :verify_signed_out_user, only: :destroy

  def create
    if @user.valid_password?(sign_in_params[:password]) #this function verify whether the passw from the user is a user password
      sign_in "user", @user #devise function & also generate a token on authentication
      json_response "Signed in Successfully" , true, {user: @user}, :ok
    else
      json_response "password is incorrect", false , {}, :unauthorized
    end
  end

  #logout
  def destroy
    sign_out @user
    @user.generate_new_authetication_token
    json_response  "Logout Successfully" , true, {}, :ok
  end

  private

  def sign_in_params
    params.require(:sign_in).permit(:email, :password)
  end

  def load_user
    @user = User.find_for_database_authentication(email: sign_in_params[:email])
    if @user
      return @user
    else
      json_response "Cannot get user", false , {}, :not_found
    end
  end

  def valid_token
    @user = User.find_by authentication_token: request.headers["AUTH-TOKEN"]
    if @user
      return @user
    else
      json_response " Invaid Token" , false, {}, :unauthorized
    end
  end
end
