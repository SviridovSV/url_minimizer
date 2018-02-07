desc 'This task is called by the Heroku scheduler add-on'
task :store_data => :environment do
  puts 'Updating feed...'
  urls = Url.all
  urls.each(&:fetch_stat_from_redis)
  puts 'done.'
end
