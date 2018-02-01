class Url < ApplicationRecord
  belongs_to :user

  validates :long_url, presence: true
  validates :short_url, uniqueness: true, if: :custom_short_url?
  after_create :ensure_short_url_has_a_value

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
