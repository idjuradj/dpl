class Link < ActiveRecord::Base
	acts_as_votable
	belongs_to :user
	has_many :comments
	has_many :taggings
	has_many :tags, through: :taggings

	# za link je obavezan title
  	validates :title, :presence => true

  	# validiranje inputa na osnovu rubijevog URI regularnog izraza
  	validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true

	def self.search(search)
  		where("title LIKE ?", "%#{search}%")
	end

	def self.tagged_with(name)
		Tag.find_by_name!(name).links
	end

	def tag_list
		tags.map(&:name).join(", ")
	end

	def tag_list=(names)
		self.tags = names.split(",").map do |name|
			Tag.where(name: name.strip).first_or_create!
		end
	end

end
