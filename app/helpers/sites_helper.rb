#coding: utf-8
module SitesHelper

	def get_all_labels
		list=Array.new
		Site.select(:label).uniq.each do |site|
			list.push site.label unless site.label.nil? || site.label.blank?
		end
		return list
	end

end
