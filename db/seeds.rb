# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
SearchEngine.create!(:name=>"Google",:url=>"http://www.google.com/search?hl=zh-CN&q=")
SearchEngine.create!(:name=>"百度",:url=>"http://www.baidu.com/s?wd=")
