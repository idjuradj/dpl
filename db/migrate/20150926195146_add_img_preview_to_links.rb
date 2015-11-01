class AddImgPreviewToLinks < ActiveRecord::Migration
  def change
    add_column :links, :img_preview, :string
  end
end
