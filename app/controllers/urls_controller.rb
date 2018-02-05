class UrlsController < ApplicationController
  before_action :set_url, only: [:show]

  def index
    code_str = JSON.parse($redis.get("#{params[:short_url]}"), symbolize_names: true)
    if code_str.blank?
      url = Url.find_by(short_url: params[:short_url])
      if url
        code_str = {
          long_url: url.long_url,
          created_at: url.created_at,
          life_term: url.life_term,
          delay_time: url.delay_time,
          stat: []
        }
        $redis.set(url.short_url, code_str.to_json)
      else
        redirect_to new_url_path, notice: 'Can not find this link. Create it.'
      end
    end
    unless code_str[:life_term].blank?
      if code_str[:created_at].to_time+code_str[:life_term].to_i < Time.now
        redirect_to new_url_path, notice: 'This link is not active already.'
        return
      end
    end
    unless code_str[:delay_time].blank?
      if code_str[:created_at].to_time+code_str[:delay_time].to_i > Time.now
        redirect_to new_url_path, notice: 'This link is not active yet.'
        return
      end
    end
    code_str[:stat] << [Time.now, request.user_agent]
    $redis.set("#{params[:short_url]}", code_str.to_json)
    redirect_to code_str[:long_url]
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

  # def fetch_long_url
  #   @url = $redis.get("#{params[:short_url]}")
  # end

  def set_url
    @url = Url.find(params[:id])
  end

  def url_params
    params.require(:url).permit(:long_url, :short_url, :life_term, :delay_time, :user_id)
  end
end
