class ApplicationController < ActionController::API

  before_action :doorkeeper_authorize!

  respond_to :json

  private

  def current_user
    @current_user ||= User.find(doorkeeper_token[:resource_owner_id])
  end
end
