  class ImagesController < ActiveStorage::BaseController
    include ActiveStorage::SetBlob

    def show
      expires_in 5.years, public: true

      representation = @blob.representation(params[:variation_key]).processed

      response.headers["Content-Type"] = representation.blob.content_type
      response.headers["Content-Disposition"] = ActionDispatch::Http::ContentDisposition.format(
        disposition: "inline",
        filename: @blob.filename.sanitized
      )

      @blob.service.download(representation.key) do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end
  end