# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# populate results from the results.json file.
# i need to cmmit these to elasticsearch.
# into the correlations index.

Result.delete_all
json = JSON.parse(IO.read("#{Rails.root}/db/results.json"))
json["results"].each do |result|
	r = Result.new(result)
	r.save
end