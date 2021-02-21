require "test_helper"

class PendingNotificationTest < ActiveSupport::TestCase
  test "tracks a pending loan_update notification" do
    member = create(:member)
    notification = assert_difference("PendingNotification.count") {
      PendingNotification.track :loan_update, tracked_id: 15, member_id: member.id
    }

    assert_equal notification.kind, "loan_update"
    assert_equal notification.loan_ids, [15]
    assert_equal notification.hold_ids, []
    assert_equal notification.renewal_request_ids, []
    assert notification.created_at
    assert notification.updated_at
  end

  test "updates a pending loan_update notification" do
    member = create(:member)

    PendingNotification.create!(kind: "loan_update", member_id: member.id, loan_ids: [14])

    notification = assert_no_difference("PendingNotification.count") {
      PendingNotification.track :loan_update, tracked_id: 15, member_id: member.id
    }

    assert_equal notification.kind, "loan_update"
    assert_equal notification.loan_ids, [14, 15]
    assert_equal notification.hold_ids, []
    assert_equal notification.renewal_request_ids, []
    assert notification.created_at
    assert notification.updated_at
  end

  test "removes a pending loan_update notification" do
    member = create(:member)

    PendingNotification.create!(kind: "loan_update", member_id: member.id, loan_ids: [15])

    notification = assert_no_difference("PendingNotification.count") {
      PendingNotification.untrack :loan_update, tracked_id: 15, member_id: member.id
    }

    assert_equal notification.kind, "loan_update"
    assert_equal notification.loan_ids, []
    assert_equal notification.hold_ids, []
    assert_equal notification.renewal_request_ids, []
    assert notification.created_at
    assert notification.updated_at
  end

  test "tracks a pending hold_available notification" do
    member = create(:member)
    notification = assert_difference("PendingNotification.count") {
      PendingNotification.track :hold_available, tracked_id: 112, member_id: member.id
    }

    assert_equal notification.kind, "hold_available"
    assert_equal notification.loan_ids, []
    assert_equal notification.hold_ids, [112]
    assert_equal notification.renewal_request_ids, []
    assert notification.created_at
    assert notification.updated_at
  end

  test "updates a pending hold_available notification" do
    member = create(:member)

    PendingNotification.create!(kind: "hold_available", member_id: member.id, hold_ids: [14])

    notification = assert_no_difference("PendingNotification.count") {
      PendingNotification.track :hold_available, tracked_id: 339, member_id: member.id
    }

    assert_equal notification.kind, "hold_available"
    assert_equal notification.loan_ids, []
    assert_equal notification.hold_ids, [14, 339]
    assert_equal notification.renewal_request_ids, []
    assert notification.created_at
    assert notification.updated_at
  end

  test "finds waiting notifications" do
    member = create(:member)

    not_ready_notification = PendingNotification.create!(
      kind: "loan_update", member_id: member.id, hold_ids: [14], updated_at: 4.minutes.ago
    )
    existing_notification = PendingNotification.create!(
      kind: "hold_available", member_id: member.id, hold_ids: [14], updated_at: 6.minutes.ago
    )

    waiting = []
    assert_difference("PendingNotification.count", -1) do
      PendingNotification.each_ready_notification do |notification|
        waiting << notification
      end
    end

    assert_equal [existing_notification], waiting
    not_ready_notification.reload # ensure it still exists
  end
end
