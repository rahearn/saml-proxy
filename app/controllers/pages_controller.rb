class PagesController < ApplicationController
  def home
    if Rails.env.production?
      redirect_to "https://gsa.gitlab-dedicated.us", allow_other_host: true
    end
  end
end
