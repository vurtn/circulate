require "application_system_test_case"

class EmbeddedItemsTest < ApplicationSystemTestCase
  include ItemsSystemTestMethods

  private def visit_items_index
    visit "/embed_test.html"
  end

  private def visit_item_page(item)
    visit "/embed_test.html#item_id=#{item.to_param}"
  end
end
