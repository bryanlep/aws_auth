defmodule AWSAuth.Encoding.Data do
  @moduledoc """
  Utilities for encoding data according to AWS specifications.
  """

  @doc """
  Encodes data into base 16 hexidecimal.
  """
  @spec encode_hex(binary) :: String.t
  def encode_hex(data) do
    Base.encode16(data)
    |> String.downcase
  end

  @doc """
  Encodes data into a SHA256 hash digest.
  """
  @spec encode_hash_sha256(iodata | nil) :: binary
  def encode_hash_sha256(nil), do: encode_hash_sha256("")
  def encode_hash_sha256(data) do
    :crypto.hash(:sha256, data)
  end

  @doc """
  Computes the SHA256 HMAC of the data with the key.
  """
  @spec encode_hmac_sha256(iodata, binary) :: binary
  def encode_hmac_sha256(data, key) do
    :crypto.hmac(:sha256, key, data)
  end

end
