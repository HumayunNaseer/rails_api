class Api::V1::UsersController < ApplicationController


  def facebook
      if params[:facebook_access_token]
        graph = Koala::Facebook::API.new params[:facebook_access_token]
        user_data = graph.get_object("me?fields=name,email,id,picture") rescue nil

        return render json: {error: "user not found" }, status: :not_found if user_data.nil?

        user = User.find_by email: user_data["email"]
        if user
          user.generate_new_authetication_token
          json_response "User Information & already exist" , true, {user: user}, :ok
          # return render json: { status: true, message: 'User already exist' }, status: :ok
        else
          user =User.new(email: user_data["email"],
                          uid: user_data["id"],
                          provider: "facebook",
                          image: user_data["picture"]["data"]["url"],
                          password: Devise.friendly_token[0,20])

          user.authentication_token =User.generate_unique_secure_token

          if user.save
            json_response "login Facebook Successfully ", true, {user: user}, :ok
            # return render json: { status: true, message: 'Login' }, status: :ok
          else
            # json_response user.errors, false, {}, :unprocessable_entity
            render json: {error: "User is not able to save" }, status: :not_found
          end
        end
      else
        # json_response "Missing facebook access token ", false, {}, :unprocessable_entity
        render json: {error: "Missing facebook token" }, status: :not_found

      end
    end

end
