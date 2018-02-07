class Url < ApplicationRecord
  belongs_to :user
  has_many :statistics

  validates :long_url, presence: true
  validates :short_url, uniqueness: true, if: :custom_short_url?
  validates :short_url, uniqueness: true, on: :update
  validates :life_term, :delay_time, numericality: { only_integer: true }, allow_blank: true

  after_create :ensure_short_url_has_a_value

  def fetch_stat_from_redis
    statistics_insert_vals = []
    loop do
      stat_data = $redis.lpop(self.short_url)
      break if stat_data.blank?
      statistic = JSON.parse(stat_data)
      client = DeviceDetector.new(statistic.last)
      statistics_insert_vals << "('#{statistic.first}',#{sql_connect.quote(client.device_type)},#{sql_connect.quote(client.os_name)},#{self.id})"
    end
    sql_transaction_for_array(statistics_insert_vals)
  end

  def url_errors
    errors = []
    errors << 'Can not find this link. Create it.' if self.id.nil?
    errors << 'This link is not active already.'   if self.life_term && self.created_at + self.life_term < Time.now
    errors << 'This link is not active yet.'       if self.delay_time && self.created_at + self.delay_time > Time.now
    errors
  end

  def save_stat_to_redis(user_info)
    $redis.lpush(self.short_url, [Time.now.to_datetime.to_s(:db), user_info].to_json)
  end

  private

  def sql_connect
    sql ||= ActiveRecord::Base.connection
  end

  def ensure_short_url_has_a_value
    unless custom_short_url?
      self.short_url = generate_code
      self.save
    end
  end

  def sql_transaction_for_array(array)
    statistics_insert_sql = "INSERT INTO statistics (stat_date,gadget,browser,url_id) VALUES "
    array.in_groups_of(200, false).each do |group|
      sql_connect.transaction do
        sql_connect.execute statistics_insert_sql + group.join(",") + ";"
      end
    end
  end

  def custom_short_url?
    !self.short_url.empty?
  end

  def generate_code
    hashids = Hashids.new(ENV['HASHIDS_PHRASE'])
    hash = hashids.encode(self.id, self.user_id)
  end
end
