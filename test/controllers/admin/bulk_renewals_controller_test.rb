require "test_helper"

module Admin
  class BulkRenewalsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = create(:admin_user)
      sign_in @admin
    end

    test "should renew all renewable loans" do
      # renew one item
      renewable_item = create(:item)

      # don't renew an item with a hold
      held_item = create(:item)
      create(:hold, item: held_item)

      # an item a member could have renewed themselves
      member_renewable_policy = create(:member_renewable_borrow_policy)
      member_renewable_item = create(:item, borrow_policy: member_renewable_policy)

      # don't renew an item that can't be renewed
      unrenewable_policy = create(:borrow_policy, renewal_limit: 0)
      unrenewable_item = create(:item, borrow_policy: unrenewable_policy)

      member = create(:verified_member)
      renewable_loan = create(:loan, item: renewable_item, member: member)
      held_loan = create(:loan, item: held_item, member: member)
      member_renewable_loan = create(:loan, item: member_renewable_item, member: member)
      unrenewable_loan = create(:loan, item: unrenewable_item, member: member)

      assert_difference("Loan.count", 2) do
        put admin_bulk_renewal_url(member)
      end

      assert_redirected_to admin_member_url(member)

      assert renewable_loan.reload.ended?
      assert_equal 1, renewable_loan.renewals.count

      assert member_renewable_loan.reload.ended?
      assert_equal 1, member_renewable_loan.renewals.count

      assert_equal 0, held_loan.renewals.count
      assert_equal 0, unrenewable_loan.renewals.count
    end
  end
end
