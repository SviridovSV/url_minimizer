class UrlsController < ApplicationController
  skip_before_action :require_login, only: [:index]
  before_action :set_url, only: [:show]

  def index
    @urls = current_user ? current_user.urls : nil
  end

  def new
    @url = Url.new
  end

  def create
    @url = Url.new(url_params)
    if @url.save
      redirect_to url_path(@url), notice: 'Your short link was created succesfully'
    else
      flash.now[:alert] = 'Creation of short link is failed'
      render :new
    end
  end

  def show
  end

  def fullpath
    url = Url.find_by(short_url: params[:short_url]) || Url.new
    errors = url.url_errors
    if errors.blank?
      url.save_stat_to_redis(request.user_agent)
      redirect_to url.long_url
    else
      redirect_to new_url_path, notice: errors.join("; ")
    end
  end

  private

  def set_url
    @url = Url.find(params[:id])
  end

  def url_params
    params.require(:url).permit(:long_url, :short_url, :life_term, :delay_time, :user_id)
  end
end
