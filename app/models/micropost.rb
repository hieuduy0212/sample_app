class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: Settings.img.size_250_250
  end

  validates :content, presence: true,
    length: {maximum: Settings.digits.digit_140}

  validates :image,
            content_type: {in: Settings[:validates][:img][:content_type],
                           message: :content_type},
            size: {less_than: Settings[:validates][:img][:max_size],
                   message: :size}

  scope :newest, ->{order created_at: :desc}
end
