class PagesController < ApplicationController
  def index
    if current_user
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def under_construction
  end
end
