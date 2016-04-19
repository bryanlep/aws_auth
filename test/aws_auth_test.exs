defmodule AWSAuthTest do
  use ExUnit.Case
  doctest AWSAuth

  alias AWSAuth.Credentials
  alias AWSAuth.CanonicalRequest
  import AWSAuth.Encoding.Data
  import AWSAuth.Encoding.Date


  setup do
    bucket = "examplebucket"
    datetime = {{2013, 5, 24}, {0, 0, 0}}
    credentials = %Credentials{access_key: "AKIAIOSFODNN7EXAMPLE",
                               secret_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
                               datetime: datetime,
                               region: "us-east-1",
                               service: "s3"}

    {:ok, [credentials: credentials,
           bucket: bucket,
           uri: URI.parse("https://#{bucket}.s3.amazonaws.com"),
           datetime: datetime]}
  end

  test "GET request calculation", %{credentials: credentials, uri: uri} do
    body = ""

    headers = [host: uri.host,
               range: "bytes=0-9",
               "x-amz-date": encode_iso8601(credentials.datetime),
               "x-amz-content-sha256": CanonicalRequest.encode_payload(body)]

    expected_values = [
      request: """
      GET
      /test.txt

      host:examplebucket.s3.amazonaws.com
      range:bytes=0-9
      x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
      x-amz-date:20130524T000000Z

      host;range;x-amz-content-sha256;x-amz-date
      e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
      """ |> String.strip,
      string_to_sign: """
      AWS4-HMAC-SHA256
      20130524T000000Z
      20130524/us-east-1/s3/aws4_request
      7344ae5b7ee6c3e7e6b0fe0640412a37625d1fbfff95c48bbb2dc43964946972
      """ |> String.strip,
      signing_key: "dbb893acc010964918f1fd433add87c70e8b0db6be30c1fbeafefa5ec6ba8378",
      signature: "f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41",
      authorization_header: "AWS4-HMAC-SHA256"
        <> " Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,"
        <> "SignedHeaders=host;range;x-amz-content-sha256;x-amz-date,"
        <> "Signature=f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41"
    ]

    test_calculations(credentials,
                      "GET",
                      "#{uri}/test.txt",
                      headers,
                      body,
                      expected_values)
  end

  test "GET root request calculation", %{credentials: credentials, uri: uri} do
    body = ""

    headers = [host: uri.host,
               "x-amz-date": encode_iso8601(credentials.datetime),
               "x-amz-content-sha256": CanonicalRequest.encode_payload(body)]

    expected_values = [
      request: """
      GET
      /
      max-keys=2&prefix=J
      host:examplebucket.s3.amazonaws.com
      x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
      x-amz-date:20130524T000000Z

      host;x-amz-content-sha256;x-amz-date
      e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
      """ |> String.strip,
      string_to_sign: """
      AWS4-HMAC-SHA256
      20130524T000000Z
      20130524/us-east-1/s3/aws4_request
      df57d21db20da04d7fa30298dd4488ba3a2b47ca3a489c74750e0f1e7df1b9b7
      """ |> String.strip,
      signing_key: "dbb893acc010964918f1fd433add87c70e8b0db6be30c1fbeafefa5ec6ba8378",
      signature: "34b48302e7b5fa45bde8084f4b7868a86f0a534bc59db6670ed5711ef69dc6f7",
      authorization_header: "AWS4-HMAC-SHA256"
        <> " Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,"
        <> "SignedHeaders=host;x-amz-content-sha256;x-amz-date,"
        <> "Signature=34b48302e7b5fa45bde8084f4b7868a86f0a534bc59db6670ed5711ef69dc6f7"
    ]

    test_calculations(credentials,
                      "GET",
                      "#{uri}?max-keys=2&prefix=J",
                      headers,
                      body,
                      expected_values)
  end

  test "PUT request calculation", %{credentials: credentials, uri: uri} do
    body = "Welcome to Amazon S3."

    headers = [host: uri.host,
               date: "Fri, 24 May 2013 00:00:00 GMT",
               "x-amz-date": encode_iso8601(credentials.datetime),
               "x-amz-storage-class": "REDUCED_REDUNDANCY",
               "x-amz-content-sha256": CanonicalRequest.encode_payload(body)]

    expected_values = [
      request: """
      PUT
      /test%24file.text

      date:Fri, 24 May 2013 00:00:00 GMT
      host:examplebucket.s3.amazonaws.com
      x-amz-content-sha256:44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072
      x-amz-date:20130524T000000Z
      x-amz-storage-class:REDUCED_REDUNDANCY

      date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class
      44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072
      """ |> String.strip,
      string_to_sign: """
      AWS4-HMAC-SHA256
      20130524T000000Z
      20130524/us-east-1/s3/aws4_request
      9e0e90d9c76de8fa5b200d8c849cd5b8dc7a3be3951ddb7f6a76b4158342019d
      """ |> String.strip,
      signing_key: "dbb893acc010964918f1fd433add87c70e8b0db6be30c1fbeafefa5ec6ba8378",
      signature: "98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd",
      authorization_header: "AWS4-HMAC-SHA256"
        <> " Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,"
        <> "SignedHeaders=date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class,"
        <> "Signature=98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd"
    ]

    test_calculations(credentials,
                      "PUT",
                      "#{uri}/test$file.text",
                      headers,
                      body,
                      expected_values)
  end


  ## Helper functions

  @doc false
  defp test_calculations(credentials, method, uri, headers, body, expected_values) do
    request = CanonicalRequest.build(method, uri, headers, body)
    assert "#{request}" == expected_values[:request]
   
    string_to_sign = AWSAuth.string_to_sign(request, credentials)
    assert string_to_sign == expected_values[:string_to_sign]

    signing_key = AWSAuth.signing_key(credentials)
    assert encode_hex(signing_key) == expected_values[:signing_key]

    signature = AWSAuth.signature_for(request, credentials)
    assert signature == expected_values[:signature]
    assert AWSAuth.signature(string_to_sign, signing_key) == expected_values[:signature]

    assert AWSAuth.authorization_header(request, credentials, signature) == expected_values[:authorization_header]
  end

end
