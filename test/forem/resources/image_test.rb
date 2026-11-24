require "test_helper"
require "stringio"
require "tempfile"

class Forem::ImageTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/images", Forem::Image.resource_path
  end

  def test_create_with_io_sends_multipart_upload
    body = '{"url":"https://media.dev.to/uploads/cover.png"}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/images", status: 201, body: body)
    requestor = make_requestor(mock_http)

    io = StringIO.new("\x89PNG\r\n\x1a\nfake-bytes".b)
    result = Forem::Image.create(image: io, filename: "cover.png", content_type: "image/png", requestor: requestor)

    assert_instance_of Forem::Image, result
    assert_equal "https://media.dev.to/uploads/cover.png", result.url
    assert_equal "POST", captured[:method]
    assert_equal "/api/images", captured[:path]
    assert_match(%r{\Amultipart/form-data; boundary=----ForemRubyBoundary}, captured[:headers]["content-type"])
    assert_includes captured[:body], 'Content-Disposition: form-data; name="image"; filename="cover.png"'
    assert_includes captured[:body], "Content-Type: image/png"
    assert_includes captured[:body], "fake-bytes"
  end

  def test_create_with_file_path_infers_filename_and_content_type
    body = '{"url":"https://media.dev.to/uploads/photo.jpg"}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/images", status: 201, body: body)
    requestor = make_requestor(mock_http)

    Tempfile.create(["photo", ".jpg"]) do |tf|
      tf.binmode
      tf.write("jpeg-data")
      tf.flush

      result = Forem::Image.create(image: tf.path, requestor: requestor)
      assert_equal "https://media.dev.to/uploads/photo.jpg", result.url
      assert_includes captured[:body], "Content-Type: image/jpeg"
      assert_includes captured[:body], "jpeg-data"
    end
  end

  def test_create_rejects_invalid_image_type
    assert_raises(ArgumentError) do
      Forem::Image.create(image: 12345)
    end
  end

  def test_generate
    body = '{"url":"https://media.dev.to/generated/robot.png"}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/images/generate", status: 201, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::Image.generate({ prompt: "A robot reading a book", aspect_ratio: "16:9" }, requestor: requestor)
    assert_instance_of Forem::Image, result
    assert_equal "https://media.dev.to/generated/robot.png", result.url
    assert_equal "POST", captured[:method]
    assert_equal "/api/images/generate", captured[:path]
    assert_equal({ "prompt" => "A robot reading a book", "aspect_ratio" => "16:9" }, JSON.parse(captured[:body]))
  end
end
