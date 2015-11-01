class TagsController < ApplicationController

  respond_to :html

  def index
    @tags = Tag.all
    respond_with(@tags)
  end

end