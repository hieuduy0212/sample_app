class User < ApplicationRecord
  validates :email, presence: true,
    length: {maximum: Settings[:validates][:email][:length]},
    format: {with: Regexp.new(Settings[:validates][:email][:regex], "i")},
    uniqueness: {case_sensitive: false}
  validates :name, presence: true
  validates :password, presence: true,
    length: {minimum: Settings.digits.digit_6}, allow_nil: true

  before_save :downcase_email
  before_create :create_activation_digest

  has_secure_password

  attr_accessor :remember_token, :activation_token

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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_column :remember_digest, nil
  end

  def send_mail_activate
    UserMailer.account_activation(self).deliver_now
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  private
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
