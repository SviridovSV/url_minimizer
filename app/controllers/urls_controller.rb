class UrlsController < ApplicationController
  before_action :set_url, only: [:show]

  def new
    @url = Url.new
  end

  def create
    @user = Url.new(url_params)
    if @url.save
      redirect_to url_path(@url), notice: 'Your short link was created succesfully'
    else
      flash.now[:alert] = 'Creation of short link is failed'
      render :new
    end
  end

  def show
  end

  private
  def set_url
    @url = Url.find(params[:id])
  end

  def url_params
    params.require(:url).permit(:long_url, :short_url, :life_term, :delay_time, :user_id)
  end
end
