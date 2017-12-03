class ImagesQuery < BaseQuery
	def self.single(image)
		{
			id: image.id,
	  		image: image.file_url,
	  		thumb: image.file.url(:thumb),
	  		medium: image.file.url(:medium),
	  		created_at: image.created_at
		}
	end
end