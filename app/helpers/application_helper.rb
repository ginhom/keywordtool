#coding: utf-8
module ApplicationHelper
	def get_all_site_names
		list=Array.new
		Site.select(:name).uniq.each do |site|
			list.push site.name
		end
		return list
	end
end
