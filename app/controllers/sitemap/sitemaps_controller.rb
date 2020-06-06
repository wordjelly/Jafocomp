class Sitemap::SitemapsController < ApplicationController

	def create
		sitemap =  SiteMap::SiteMap.new(permitted_params.fetch(:sitemap))
		sitemap.save
	end

	def permitted_params
		params.permit(:sitemap => [:exchange_name, :exchange_id])
	end

end