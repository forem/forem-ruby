module Forem
  module Services
    # Service for interacting with the Forem Profile Images API.
    #
    # Retrieves profile image URLs for a given user or organization.
    # Access via {Client#profile_images}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   image_info = client.profile_images.retrieve("jsmith")
    #
    # @see ProfileImage
    # @see https://developers.forem.com/api/v1#tag/profile-images
    class ProfileImageService < BaseService
      # Retrieve profile image details for a user or organization by username.
      #
      # @param username [String] the username of the user or organization
      # @param opts [Hash] per-request options
      # @return [ProfileImage] profile image data including the image URL
      #
      # @example
      #   image = client.profile_images.retrieve("jsmith")
      #   puts image.profile_image
      #
      # @see https://developers.forem.com/api/v1#tag/profile-images/operation/getProfileImage
      def retrieve(username, opts = {})
        ProfileImage.retrieve(username, opts_with_requestor(opts))
      end
    end
  end
end
