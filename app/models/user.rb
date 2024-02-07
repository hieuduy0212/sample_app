class User < ApplicationRecord
  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create string, cost:
  end

  validates :email, format: {with: Regexp.new(Settings.validates.email.regex, "i")}
  validates :email, length: {maximum: Settings.validates.email.length}
  validates :email, presence: true
  validates :email, uniqueness: {case_sensitive: false}
  validates :name, presence: true

  has_secure_password

  before_save :downcase_email

  private
  def downcase_email
    email.downcase!
  end
end
