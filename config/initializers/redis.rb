$redis = Redis::Namespace.new("url_minimizer", :redis => Redis.new)