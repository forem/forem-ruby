require "cgi"

module Forem
  # Represents the profile image associated with a Forem user or organization.
  #
  # Retrieve a user's profile image URL by their username.
  #
  # Profile images are avatar graphics that appear alongside user and
  # organization names across the Forem UI. This resource exposes a single
  # retrieve operation that looks up the image by username (or organization
  # slug) and returns URLs to the image at various sizes.
  #
  # @example Retrieve a user's profile image
  #   image = Forem::ProfileImage.retrieve("alice")
  #   puts image.profile_image
  #   puts image.profile_image_90
  #
  # @example Retrieve an organization's profile image
  #   image = Forem::ProfileImage.retrieve("acme-corp")
  #   puts image.profile_image
  #
  # @see https://developers.forem.com/api/v1
  class ProfileImage < APIResource
    OBJECT_NAME = "profile_image"
    RESOURCE_PATH = "/api/profile_images"

    # Retrieve the profile image URLs for a user or organization.
    #
    # Sends a GET request to +/api/profile_images/:username+.
    #
    # @param username [String] the username or organization slug to look up
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ProfileImage] object containing +profile_image+ and +profile_image_90+ URL fields
    # @example
    #   image = Forem::ProfileImage.retrieve("alice")
    #   puts image.profile_image        # full-size URL
    #   puts image.profile_image_90     # 90px thumbnail URL
    # @see https://developers.forem.com/api/v1
    def self.retrieve(username, opts = {})
      resp = request(:get, "#{resource_path}/#{CGI.escape(username)}", {}, opts)
      construct_from(resp.parsed_body)
    end
  end
end
