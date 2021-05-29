module Admin
  class ItemHoldsPositionController < BaseController
    def update
      @item = Item.find(params[:item_id])
      @hold = @item.active_holds.find(params[:hold_id])

      if @hold.update(position: params[:position])
        @holds = @item.active_holds.order(position: :asc)
        render "admin/item_holds/index"
      end
    end
  end
end
