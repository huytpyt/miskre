class ImagesQuery < BaseQuery
	def self.single(image)
		{
			id: image.id,
	  		original: image.file.url,
	  		thumb: image.file.url(:thumb),
	  		medium: image.file.url(:medium),
	  		created_at: image.created_at
		}
	end
end