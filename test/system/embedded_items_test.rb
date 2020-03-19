require "application_system_test_case"

class EmbeddedItemsTest < ApplicationSystemTestCase
  include ItemsSystemTestMethods

  private def visit_items_index
    visit "/embed_test.html"
  end
end