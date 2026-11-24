module Forem
  # Represents a discoverable or root subforem on a Forem instance.
  #
  # Sends a GET request to +/api/subforems+.
  #
  # == Subforem Fields
  #
  # - +id+ (Integer)
  # - +domain+ (String)
  # - +root+ (Boolean)
  # - +name+ (String)
  # - +description+ (String)
  # - +logo_image_url+ (String)
  # - +cover_image_url+ (String)
  #
  # @example List subforems
  #   subforems = client.subforems.list
  #   subforems.each { |s| puts "#{s.name} (#{s.domain})" }
  #
  # @see https://developers.forem.com/api/v1
  class Subforem < APIResource
    extend APIOperations::List

    OBJECT_NAME = "subforem"
    RESOURCE_PATH = "/api/subforems"
  end
end
