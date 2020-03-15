module Embed
  class AssetsController < ApplicationController
    include Webpacker::Helper

    def js
      redirect_to helpers.asset_pack_url("embed.js")
    end

    def css
      redirect_to helpers.asset_pack_url("embed_styles.css")
    end
  end
end
