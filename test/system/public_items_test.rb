require "application_system_test_case"

class PublicItemsTest < ApplicationSystemTestCase
  include ItemsSystemTestMethods

  private def visit_items_index
    visit items_url
  end

  def visit_item_page(item)
    visit item_url(item)
  end
end
