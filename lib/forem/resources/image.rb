module Forem
  # Represents an uploaded or AI-generated image for use in Forem articles.
  #
  # Supports:
  #   - +create+   — POST /api/images (multipart file upload)
  #   - +generate+ — POST /api/images/generate (AI image generation)
  #
  # Returned objects expose +url+, which can be embedded in +body_markdown+ or
  # assigned as an article's +main_image+.
  #
  # @example Upload a local image file
  #   img = client.images.create(image: "/path/to/cover.png")
  #   puts img.url
  #
  # @example Upload from an IO object
  #   img = client.images.create(image: io, filename: "cover.png", content_type: "image/png")
  #   puts img.url
  #
  # @example Generate an image with AI
  #   img = client.images.generate(prompt: "A minimalist ruby gem icon", aspect_ratio: "16:9")
  #   puts img.url
  #
  # @see https://developers.forem.com/api/v1
  class Image < APIResource
    OBJECT_NAME = "image"
    RESOURCE_PATH = "/api/images"

    CONTENT_TYPES = {
      ".png"  => "image/png",
      ".jpg"  => "image/jpeg",
      ".jpeg" => "image/jpeg",
      ".gif"  => "image/gif",
      ".webp" => "image/webp",
      ".avif" => "image/avif",
      ".svg"  => "image/svg+xml"
    }.freeze

    # Upload an image via +POST /api/images+ using +multipart/form-data+.
    #
    # @param image [String, IO] a file path String or an IO-like object
    #   responding to +#read+.
    # @param filename [String, nil] optional filename (inferred from path or
    #   +image.path+ when omitted).
    # @param content_type [String, nil] optional MIME type (inferred from
    #   filename extension when omitted).
    # @param opts [Hash] per-request options (e.g., +:api_key+).
    # @return [Forem::Image] object with the hosted +url+.
    def self.create(image:, filename: nil, content_type: nil, **opts)
      requestor = opts[:requestor]
      opened_file = nil

      io = if image.is_a?(String)
             opened_file = File.open(image, "rb")
           elsif image.respond_to?(:read)
             image
           else
             raise ArgumentError, "image must be a file path String or an IO object"
           end

      resolved_filename = filename ||
        (image.is_a?(String) ? File.basename(image) : nil) ||
        (io.respond_to?(:path) && io.path ? File.basename(io.path.to_s) : "image")
      resolved_content_type = content_type || infer_content_type(resolved_filename)

      resp = request(
        :post,
        resource_path,
        { image: { io: io, filename: resolved_filename, content_type: resolved_content_type } },
        opts.merge(multipart: true)
      )
      construct_from(resp.parsed_body, requestor: requestor)
    ensure
      opened_file&.close
    end

    # Generate an AI image via +POST /api/images/generate+.
    #
    # @param params [Hash] generation parameters
    # @option params [String] :prompt text prompt describing the image (required, max 1000 chars)
    # @option params [String] :aspect_ratio optional aspect ratio (e.g. +"16:9"+, +"1:1"+)
    # @param opts [Hash] per-request options
    # @return [Forem::Image] object with the generated image +url+.
    def self.generate(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:post, "#{resource_path}/generate", params, opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end

    def self.infer_content_type(filename)
      CONTENT_TYPES.fetch(File.extname(filename.to_s).downcase, "application/octet-stream")
    end
    private_class_method :infer_content_type
  end
end
