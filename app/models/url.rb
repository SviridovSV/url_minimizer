class Url < ApplicationRecord
  belongs_to :user

  validates :long_url, presence: true
  validates :short_url, uniqueness: true, if: :custom_short_url?
  validates :short_url, uniqueness: true, on: :update
  validates :life_term, :delay_time, numericality: { only_integer: true }

  after_create :ensure_short_url_has_a_value
  after_save :send_data_to_redis

  def send_data_to_redis
    $redis.set("#{self.short_url}", "#{self.long_url}")
  end

  private
  def custom_short_url?
    !self.short_url.empty?
  end

  def ensure_short_url_has_a_value
    unless custom_short_url?
      self.short_url = generate_code
      self.save
    end
  end

  def generate_code
    hashids = Hashids.new(ENV['HASHIDS_PHRASE'])
    hash = hashids.encode(self.id, self.life_term.to_i, self.delay_time.to_i, self.user_id)
  end
end
