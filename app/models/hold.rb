class Hold < ApplicationRecord
  HOLD_LENGTH = 7.days

  has_many :appointment_holds
  has_many :appointments, through: :appointment_holds

  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
  belongs_to :loan, required: false

  acts_as_list scope: :item

  scope :active, ->(now = Time.current) { where("ended_at IS NULL AND (started_at IS NULL OR started_at >= ?)", now.beginning_of_day - HOLD_LENGTH) }
  scope :inactive, ->(now = Time.current) { ended.or(expired(now)) }
  scope :ended, -> { where("ended_at IS NOT NULL") }
  scope :expired, ->(now = Time.current) { where("started_at < ?", now.beginning_of_day - HOLD_LENGTH) }
  scope :started, -> { where("started_at IS NOT NULL") }

  scope :recent_first, -> { order("created_at desc") }

  validates :item, presence: true
  validates_each :item do |record, attr, value|
    if value
      value.reload
      unless value.holdable?
        record.errors.add(attr, "can not be placed on hold")
      end
    end
  end

  def self.active_hold_count_for_item(item)
    active.where(item: item).count
  end

  def lend(loan, now: Time.current)
    update!(
      loan: loan,
      ended_at: now
    )
  end

  # active and inactive are mutually exclusive
  # ended, expired, and started check for specific states
  # and should not be used as proxies for inactive.

  # A new hold
  def active?(now = Time.current)
    !inactive?(now)
  end

  # A hold that was picked up or timed out
  def inactive?(now = Time.current)
    ended? || expired?(now)
  end

  # A hold that was picked up
  def ended?
    ended_at.present?
  end

  def start!(now = Time.current)
    update!(
      started_at: now
    )
  end

  def expires_at
    (started_at + HOLD_LENGTH).end_of_day if started_at.present?
  end

  # A hold that timed out
  def expired?(now = Time.current)
    started_at && expires_at < now
  end

  # A hold whose clock has started ticking
  def started?
    started_at.present?
  end

  def previous_active_holds(now = Time.current)
    Hold.active(now).where("position < ?", position).where(item: item).where.not(member: member).order(:position).to_a
  end

  def ready_for_pickup?(now = Time.current)
    # Holds for uncounted items are always ready to be picked up
    unless item.borrow_policy.uniquely_numbered?
      return true
    end

    # For uniquely numbered items there need to be no earlier holds
    # and the item needs to be in the library
    previous_active_holds(now).empty? && item.available?
  end

  def upcoming_appointment
    member.upcoming_appointment_of(self)
  end

  def self.start_waiting_holds(now = Time.current, &block)
    started = 0

    active(now).includes(item: :borrow_policy).find_each do |hold|
      if hold.started?
        Rails.logger.debug "[hold #{hold.id}]: already started"
        next
      end

      unless hold.ready_for_pickup?(now)
        Rails.logger.debug "[hold #{hold.id}]: not ready for pickup"
        next
      end

      Rails.logger.debug "[hold #{hold.id}]: ready to start"
      hold.start!(now)
      yield hold if block # send email
      started += 1
    end

    Rails.logger.debug "Audit active holds: started #{started}."

    started
  end
end

# a=1 b=2 c=3
# c -> a
#
#
#

def position_scope
  where(item_id: item_id)
end

before_save :set_initial_position

def set_initial_position
  self.position = position.scope.maximum(:position) + 1
end

before_update :prepare_for_position_update

def prepare_for_position_update
  return unless position_changed?

  current_position, new_position = position_changes
  change = new_position < current_position ? 1 : -1

  # move out of the way
  update_attribute(:position, position_scope.maximum(:position) + 1)

  Hold.where("position BETWEEN ? AND ?", new_pos, current_pos).update_all!("position=position+?", change * -1)
end

update!(new_pos)
