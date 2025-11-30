# Configure Resque Redis connection
redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
Resque.redis = Redis.new(url: redis_url)

# https://coderwall.com/p/o0nhuq
class CanAccessResque
  def matches?(request)
    user = request.env['warden'].user
    return false if user.blank?
    Ability.new(user).can? :manage, Resque
  end
end
