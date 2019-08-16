class ActiveStorage::RepresentationsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  def show
    expires_in ActiveStorage.service_urls_expire_in
    variant = @blob.representation(params[:variation_key])
    url = Rails.cache.fetch(cache_key(variant)) do
      variant.processed.service_url(disposition: params[:disposition])
    end
    redirect_to url
  end

  private

  def cache_key(variant)
    "active_storage/urls/#{variant.key}"
  end
end