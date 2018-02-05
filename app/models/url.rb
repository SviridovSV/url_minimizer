class Url < ApplicationRecord
  belongs_to :user
  has_many :statistics

  validates :long_url, presence: true
  validates :short_url, uniqueness: true, if: :custom_short_url?
  validates :short_url, uniqueness: true, on: :update
  validates :life_term, :delay_time, numericality: { only_integer: true }, :allow_blank => true

  after_create :ensure_short_url_has_a_value
  after_save :send_data_to_redis

  def send_data_to_redis
    $redis.set("#{self.short_url}", hash_for_redis.to_json)
  end

  def ensure_short_url_has_a_value
    unless custom_short_url?
      self.short_url = generate_code
      self.save
    end
  end

  def fetch_stat_from_redis
    stat_array = JSON.parse($redis.get("#{self.short_url}"), symbolize_names: true)
    stat_array[:stat].each do |elem|
      s = Statistic.new(url_id: self.id, date: elem.first.to_datetime)
      s.save
    end
  end

  private
  def hash_for_redis
    {
      long_url: self.long_url,
      created_at: self.created_at,
      life_term: self.life_term,
      delay_time: self.delay_time,
      stat: []
    }
  end

  def custom_short_url?
    !self.short_url.empty?
  end

  def generate_code
    hashids = Hashids.new(ENV['HASHIDS_PHRASE'])
    hash = hashids.encode(self.id, self.life_term.to_i, self.delay_time.to_i, self.user_id)
  end
end
