module Embed
  class ItemsController < ::ItemsController
    layout false

    def index
      super
    end

    def show
      super
    end

    helper_method def inventory_item_path(item)
      params = {item_id: item.to_param}
      "/inventory#" + params.to_query
    end

    helper_method def inventory_path(parameters = {})
      hash = filter_params.merge(parameters).to_h.compact.to_query
      root = "/inventory"

      return root if hash.size == 0

      root + "#" + hash
    end
  end
end
