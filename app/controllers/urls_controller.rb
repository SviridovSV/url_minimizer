class UrlsController < ApplicationController
  before_action :decode_url, only: [:index]
  before_action :set_url, only: [:show, :index]

  def index
    redirect_to @url.long_url
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

  private
  def decode_url
    hashids = Hashids.new("this is my application")
    params[:id] = hashids.decode(params[:short_url].to_s).first
  end

  def set_url
    @url = Url.find(params[:id])
  end

  def url_params
    params.require(:url).permit(:long_url, :short_url, :life_term, :delay_time, :user_id)
  end
end
