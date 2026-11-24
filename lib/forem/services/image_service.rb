module Forem
  module Services
    # Service for uploading and AI-generating article images.
    #
    # Access via {Client#images}.
    #
    # @see Image
    # @see https://developers.forem.com/api/v1
    class ImageService < BaseService
      # Upload an image via +POST /api/images+ (+multipart/form-data+).
      #
      # @param image [String, IO] file path String or IO object
      # @param filename [String, nil] optional filename override
      # @param content_type [String, nil] optional MIME type override
      # @param opts [Hash] per-request options
      # @return [Image] object exposing +url+
      def create(image:, filename: nil, content_type: nil, **opts)
        Image.create(
          image: image,
          filename: filename,
          content_type: content_type,
          **opts_with_requestor(opts)
        )
      end

      # Generate an AI image via +POST /api/images/generate+.
      #
      # @param params [Hash] generation parameters (+:prompt+, optional +:aspect_ratio+)
      # @param opts [Hash] per-request options
      # @return [Image] object exposing +url+
      def generate(params = {}, opts = {})
        Image.generate(params, opts_with_requestor(opts))
      end
    end
  end
end
