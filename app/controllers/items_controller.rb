class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    scope = if params[:query]
      @query = params[:query]
      Item.search_by_anything(@query)
    elsif params[:tag]
      @tag = Tag.where(id: params[:tag]).first
      redirect_to(items_path, error: "Tag not found") && return unless @tag

      @tag.items
    else
      Item
    end

    item_scope = scope
      .listed_publicly
      .includes(:tags, :borrow_policy, :checked_out_exclusive_loan)
      .with_attached_image
      .reorder(index_order)

    @pagy, @items = pagy(item_scope)
  end

  def show
    @item = Item.listed_publicly.find(params[:id])
  end

  private

  def index_order
    options = {
      "name" => "items.name ASC",
      "number" => "items.number ASC",
      "added" => "items.created_at DESC"
    }
    options.fetch(params[:sort]) { options["name"] }
  end

  helper_method def inventory_path(parameters = {})
    final_params = filter_params.merge(parameters).to_h.compact
    url_for(final_params)
  end

  helper_method def filter_params
    params.permit(:tag, :query)
  end
end
