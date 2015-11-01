class LinksController < ApplicationController
  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:index, :show]

  respond_to :html

  def index
    @links = Link.all

    if params[:search]
      @links = Link.search(params[:search]).order('cast(created_at as date) desc, cached_votes_score desc').page(params[:page]).per_page(10)
    
    elsif params[:tag]
      @links = Link.tagged_with(params[:tag]).page(params[:page]).per_page(10)
    else
      @links = Link.all.order('cast(created_at as date) desc, cached_votes_score desc').page(params[:page]).per_page(10)
    end

    #@links = Link.all.page(params[:page]).per_page(10)
    #Link.order(created_at: :desc, cached_votes_up: :desc)
    respond_with(@links)
  end

  def show
    respond_with(@link)
  end

  def new
    #@link = Link.new
    @link = current_user.links.build
    respond_with(@link)
  end

  def edit
    @link = Link.find(params[:id])
  end

  def create
    @link = current_user.links.build(link_params)

      if @link.url.include? "youtube.com"

        @link.img_preview = "http://i.imgur.com/YD1Dk9T.png"

      elsif !@link.url.blank?

        require 'link_thumbnailer'
        @temp = LinkThumbnailer.generate(@link.url, verify_ssl: false)
        @link.img_preview = @temp.images.first.src.to_s

      else

        @link.img_preview = "http://i.imgur.com/heSD8Ik.jpg"

      end

    @link.save
    respond_with(@link)
  end

  def update
    @link.update(link_params)
    respond_with(@link)
  end

  def destroy
    @link.destroy
    respond_with(@link)
  end

  def upvote
    @link = Link.find(params[:id])

    if current_user.voted_for? @link
      redirect_to :back
    else
      @link.upvote_by current_user
      @link.user.increase_karma
      redirect_to :back
    end
  end

  def downvote
    @link = Link.find(params[:id])

    if current_user.voted_for? @link
      redirect_to :back
    else
      @link.downvote_by current_user
      @link.user.decrease_karma
      redirect_to :back
    end

  end

  private
    def set_link
      @link = Link.find(params[:id])
    end

    def link_params
      params.require(:link).permit(:title, :url, :body, :tag_list)
    end
end
