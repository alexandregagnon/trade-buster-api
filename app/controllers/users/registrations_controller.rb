class Users::RegistrationsController < Devise::RegistrationsController
  # Skip session creation and validation, as we're using token authentication
  before_action :skip_session_storage

  respond_to :json

  # Override the create action
  def create
    build_resource(sign_up_params)

    if resource.save
      # Issue an OAuth token for the user
      token = Doorkeeper::AccessToken.create(
        resource_owner_id: resource.id,
        application_id: default_application.id,
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        scopes: "default"
      )

      render json: {
        id: resource.id,
        email: resource.email,
        token: token.token,
        token_type: "Bearer",
        expires_in: token.expires_in
      }, status: :created
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def default_application
    @default_application ||= Doorkeeper::Application.find_by(name: "StashMobileApp")
  end

  def skip_session_storage
    request.session_options[:skip] = true
  end
end
