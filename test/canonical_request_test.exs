defmodule AWSAuth.CanonicalRequestTest do
  use ExUnit.Case
#  doctest AWSAuth.CanonicalRequest

  alias AWSAuth.CanonicalRequest

  test "request construction" do
    headers = ["Host": "some.host.com",
               "Content-Type": " html ",
               "X-Amz-Content-SHA256": " something "]

    request = CanonicalRequest.build("GET",
                                     "http://some.domain.com/some/arbitrary/path?param1=aisn&aparam2=aieln",
                                     headers,
                                     "some-payload~here")

    assert request.method == "GET"
    assert request.path == "/some/arbitrary/path"
    assert request.query == "aparam2=aieln&param1=aisn"
    assert request.headers == "content-type:html\nhost:some.host.com\nx-amz-content-sha256:something\n"
    assert request.signed_headers == "content-type;host;x-amz-content-sha256"
    assert request.payload == "b0eab9745dc2dda45340e14dce49e0791c25e9190b2b1d3cfb616d4d7da0fdd4"

    assert "#{request}" == """
    GET
    /some/arbitrary/path
    aparam2=aieln&param1=aisn
    content-type:html\nhost:some.host.com\nx-amz-content-sha256:something

    content-type;host;x-amz-content-sha256
    b0eab9745dc2dda45340e14dce49e0791c25e9190b2b1d3cfb616d4d7da0fdd4
    """ |> String.strip
  end

  test "uri component parsing" do
    {path, params} = CanonicalRequest.parse_uri_components("http://sub.domain.com/this/is/a/path?key=val&another_key=value")
    assert path == "/this/is/a/path"
    assert params == [key: "val", another_key: "value"]

    {_, params} = CanonicalRequest.parse_uri_components("http://sub.domain.com/this/is/a/path?key")
    assert params == [key: nil]

    {_, params} = CanonicalRequest.parse_uri_components("http://sub.domain.com/this/is/a/path?key&anotherKey=value")
    assert params == [key: nil, anotherKey: "value"]

    {_, params} = CanonicalRequest.parse_uri_components("http://sub.domain.com/path/here")
    assert params == []

    {path, params} = CanonicalRequest.parse_uri_components("http://sub.domain.com?max-keys=2&prefix=J")
    assert path == "/"
    assert params == ["max-keys": "2", prefix: "J"]
  end

  test "query encoding" do
    # empty parameter encoding
    assert CanonicalRequest.encode_query_parameters([]) == ""
    assert CanonicalRequest.encode_query_parameters(nil) == ""

    # basic parameter encoding
    assert CanonicalRequest.encode_query_parameters([key2: "value2", key1: "value1"]) == "key1=value1&key2=value2"

    # encoding of empty parameter
    assert CanonicalRequest.encode_query_parameters([key: ""]) == "key="
    assert CanonicalRequest.encode_query_parameters([key: nil]) == "key="

    # encoding of empty parameter with non-empty parameters
    assert CanonicalRequest.encode_query_parameters([key: nil, key2: "value", akey: "another value"]) == "akey=another%20value&key=&key2=value"
  end

  test "header encoding" do
    headers = ["Host": "some.host.com",
               "Content-Type": "json/or something",
               "Accept": "anything"]

    {encoded_headers, signed_headers} = CanonicalRequest.encode_headers(headers)

    assert encoded_headers == "accept:anything\ncontent-type:json/or something\nhost:some.host.com\n"
    assert signed_headers == "accept;content-type;host"
  end

  test "payload encoding" do
    assert CanonicalRequest.encode_payload("something") == "3fc9b689459d738f8c88a3a48aa9e33542016b7a4052e001aaa536fca74813cb"
    assert CanonicalRequest.encode_payload("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    assert CanonicalRequest.encode_payload(nil) == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  end

end

