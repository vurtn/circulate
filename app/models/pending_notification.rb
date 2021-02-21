# PendingNotification bundles notifications by member and kind.
# This allows us to send aggregate emails and not spam members when
# many similar events happen over a short period of time.
#
# A good example of this is a person who is checking in or our tools.
# Each check in or out updates a Loan record, one at a time as the librarian
# updates the computer. Additionally, it's possible that the librarian might
# need to undo one of these actions, and we want the email notifications we send
# to be as accurate as possible to avoid confusion.
#
# Notifications are currently bucketed for 5 minutes, after which time a
# process that runs regularly will detect and send the actual notification. The
# PendingNotification will then be deleted from the database.
class PendingNotification < ApplicationRecord
  DELAY = 5.minutes

  TRACKED_NOTIFICATIONS = {
    loan_update: "loan_ids",
    hold_available: "hold_ids",
    renewal_request_update: "renewal_request_ids"
  }.freeze

  belongs_to :member

  scope :ready, -> { where("updated_at < ?", DELAY.ago) }

  def self.each_ready_notification(&block)
    ready.pluck(:id).each do |id|
      transaction do
        notification = find(id).lock!
        block.call(notification)
        notification.delete
      end
    end
  end

  # Register a notification to be sent in the future.
  #
  # Any additional notifications of the same type will be bundled together
  # and result in a single notification being sent.
  def self.track(kind, member_id:, tracked_id:)
    unless TRACKED_NOTIFICATIONS.key?(kind)
      raise ArgumentError.new("is not a recognized notification type")
    end

    query = query_for_upsert(
      member_id: member_id,
      kind: kind,
      column: TRACKED_NOTIFICATIONS[kind],
      id: tracked_id
    )
    find connection.insert(query, "UPSERT PENDING NOTIFICATION")
  end

  # Deregister a notification, preventing it from being sent.
  #
  # This is designed to be a best-effort deregister, but we aren't attempting to handle
  # issues of concurrency or have a defined outcome should the untrack happen concurrently
  # with a registration or query.
  def self.untrack(kind, member_id:, tracked_id:)
    unless TRACKED_NOTIFICATIONS.key?(kind)
      raise ArgumentError.new("is not a recognized notification type")
    end
    query = query_for_removal(
      member_id: member_id,
      kind: kind,
      column: TRACKED_NOTIFICATIONS[kind],
      id: tracked_id
    )
    connection.update(query, "UPSERT PENDING NOTIFICATION")
    where(member_id: member_id, kind: kind).first
  end

  def self.query_for_upsert(member_id:, kind:, column:, id:)
    params = {member_id: member_id, id: id, kind: kind}
    sanitize_sql([<<-SQL, params])
      INSERT INTO #{table_name} (member_id, kind, #{column}, created_at, updated_at) VALUES (:member_id, :kind, '{:id}', NOW(), NOW())
      ON CONFLICT (member_id, kind) DO UPDATE
      SET #{column} = array_append(pending_notifications.#{column}, :id), updated_at = NOW()
    SQL
  end

  def self.query_for_removal(member_id:, kind:, column:, id:)
    params = {member_id: member_id, id: id, kind: kind}
    sanitize_sql([<<-SQL, params])
      UPDATE #{table_name}
        SET #{column} = array_remove(pending_notifications.#{column}, :id), updated_at = NOW()
        WHERE member_id = :member_id AND kind = :kind;
    SQL
  end
end
