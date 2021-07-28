module Admin
  class ItemHoldsPositionController < BaseController
    def update
      @item = Item.find(params[:item_id])
      @hold = @item.active_holds.find(params[:hold_id])

      @hold.insert_at(params[:position].to_i)
      @holds = @item.active_holds.order(position: :asc)
      render "admin/item_holds/index"
    end
  end
end
