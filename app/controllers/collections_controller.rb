# frozen_string_literal: true

class CollectionsController < ApplicationController
  def index
    collections
  end

  def show
    collection
  end

  private

  def collections
    @collections ||= current_user.collections
  end

  def collection
    @collection ||= current_user.collections.find(params[:id])
  end
end
