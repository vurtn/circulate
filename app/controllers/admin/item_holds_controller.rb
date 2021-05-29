module Admin
  class ItemHoldsController < BaseController
    def index
      @item = Item.find(params[:item_id])
      @holds = @item.active_holds.order(position: :asc)
    end
  end
end
