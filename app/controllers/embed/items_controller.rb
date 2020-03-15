module Embed
  class ItemsController < ::ItemsController
    layout false

    def index
      super
    end

    helper_method def inventory_path(parameters = {})
      hash = filter_params.merge(parameters).to_h.compact.to_query
      root = "/inventory"

      return root if hash.size == 0

      root + "#" + hash
    end
  end
end
