defmodule AWSAuth do
  @moduledoc """
  Utilities for authenticating requests to AWS services.
  """

  alias AWSAuth.Credentials
  alias AWSAuth.CanonicalRequest
  import AWSAuth.Encoding.Data
  import AWSAuth.Encoding.Date


  @doc """
  Assembles the Authorization header value required for AWS requests.
  """
  @spec authorization_header(CanonicalRequest.t, Credentials.t, binary) :: binary
  def authorization_header(request = %CanonicalRequest{}, credentials = %Credentials{}, signature) do
    "AWS4-HMAC-SHA256 Credential=#{credentials},SignedHeaders=#{request.signed_headers},Signature=#{signature}"
  end
  
  @doc """
  Computes the signature with the credential, request, and secret key data.
  """
  @spec signature_for(CanonicalRequest.t, Credentials.t) :: binary
  def signature_for(request = %CanonicalRequest{}, credentials = %Credentials{}) do
    signature(string_to_sign(request, credentials),
              signing_key(credentials))
  end

  @doc """
  Computes the signature from the signing key and string to sign.
  """
  @spec signature(binary, binary) :: binary
  def signature(string_to_sign, signing_key),
    do: encode_hmac_sha256(string_to_sign, signing_key) |> encode_hex

  @doc """
  Creates a signing key from the credential information and secret key.
  """
  @spec signing_key(Credentials.t) :: iodata
  def signing_key(credentials = %Credentials{}) do
    {date, _} = credentials.datetime

    d_key = encode_hmac_sha256(encode_numeric_padded(date), "AWS4#{credentials.secret_key}")
    dr_key = encode_hmac_sha256(credentials.region, d_key)
    drs_key = encode_hmac_sha256(credentials.service, dr_key)
    encode_hmac_sha256("aws4_request", drs_key)
  end

  @doc """
  Creates a string to sign using the credential and canonical request data.
  """
  @spec string_to_sign(CanonicalRequest.t, Credentials.t) :: binary
  def string_to_sign(request = %CanonicalRequest{}, credentials = %Credentials{}) do
    ["AWS4-HMAC-SHA256",
     encode_iso8601(credentials.datetime),
     Credentials.scope(credentials),
     encode_hash_sha256("#{request}") |> encode_hex]
    |> Enum.join("\n")
  end

end

