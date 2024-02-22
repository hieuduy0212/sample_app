class User < ApplicationRecord
  validates :email, presence: true,
    length: {maximum: Settings[:validates][:email][:length]},
    format: {with: Regexp.new(Settings[:validates][:email][:regex], "i")},
    uniqueness: {case_sensitive: false}
  validates :name, presence: true
  validates :password, presence: true,
    length: {minimum: Settings.digits.digit_6}, allow_nil: true

  before_save :downcase_email

  has_secure_password

  attr_accessor :remember_token

  scope :order_by_name, ->{order :name}

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false unless remember_token

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_column :remember_digest, nil
  end

  private
  def downcase_email
    email.downcase!
  end
end
