class Order < ApplicationRecord
  DELIVERY_TYPE = %w[Pickup Delivery].freeze
  PAY_TYPE = %w[Cash Terminal].freeze

  has_one :promo_code, dependent: :destroy
  has_one :place, dependent: :destroy
  accepts_nested_attributes_for :place

  has_many :line_items, dependent: :destroy
  belongs_to :user, optional: true

  scope :pending, -> { where(status: 'Pending') }
  scope :complete, -> { where(status: 'Complete') }
  scope :processing, -> { where(status: 'Processing') }

  validates :first_name, :last_name, presence: true, length: { in: 2..20 }
  validates :user_number,
            presence: true,
            length: { is: 9 },
            numericality: { only_integer: true }
  validates :description, allow_nil: true, length: { in: 2..250 }
  validates :delivery_type, presence: true, acceptance: { accept: %w[Pickup Delivery] }
  validates :pay_type, presence: true, acceptance: { accept: %w[Cash Terminal] }

  def get_product(cart)
    cart.line_items.each do |line_item|
      line_item.cart_id = nil
      line_items.push(line_item)
    end
    cart.delete
  end

  private

  before_create :set_status

  def set_status
    self.status = 'Pending'
  end
end
