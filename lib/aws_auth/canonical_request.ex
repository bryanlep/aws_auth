defmodule AWSAuth.CanonicalRequest do
  @moduledoc """
  Struct containing AWS CanonicalRequest data along with utilities
  for formatting the data according to AWS specifications.
  """

  alias __MODULE__
  import AWSAuth.Encoding.URI
  import AWSAuth.Encoding.Data

  defstruct [:method, :path, :query, :headers, :signed_headers, :payload]

  @type t :: %CanonicalRequest{method: String.t,
                               path: String.t,
                               query: String.t,
                               headers: String.t,
                               signed_headers: String.t,
                               payload: binary}

  
  @doc """
  Builds a canonical request.

  The query parameters are parsed from the uri.

  Passing nil for the payload configures the request to use the
  unsigned payload option. Anything else (even the empty string "")
  uses the signed payload option.
  """
  @spec build(String.t, String.t, Keyword.t, binary | nil) :: CanonicalRequest.t
  def build(method, uri, headers, payload \\ nil) do
    {path, params} = parse_uri_components(uri)
    {encoded_headers, signed_headers} = encode_headers(headers)

    payload = case payload do
      nil -> "UNSIGNED-PAYLOAD"
      _   -> encode_payload(payload)
    end

    %CanonicalRequest{method: method,
                      path: encode_path(path),
                      query: encode_query_parameters(params),
                      headers: encoded_headers,
                      signed_headers: signed_headers,
                      payload: payload}
  end

  @doc """
  Parses the given uri for its components.

  Returns a tuple containing the absolute path string and
  a keyword list of query parameters.
  """
  @spec parse_uri_components(String.t) :: {String.t, Keyword.t}
  def parse_uri_components(uri) do
    components = URI.parse(uri)
    params = case components.query do
      nil -> []
      _   ->
        URI.query_decoder(components.query)
        |> Enum.into([], fn {key, value} -> {String.to_atom(key), value} end)
    end

    {components.path || "/", params}
  end


  @doc """
  Encodes uri query parameters according to AWS CanonicalQueryString specification.
  """
  @spec encode_query_parameters(Keyword.t) :: String.t
  def encode_query_parameters(nil), do: ""
  def encode_query_parameters([]),  do: ""
  def encode_query_parameters(params) do
    Enum.map(params, fn {k, v} -> {encode_component(k), encode_component(v)} end)
    |> Enum.sort(fn {k1, _}, {k2, _} -> k1 <= k2 end)
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
  end

  @doc """
  Encodes headers and signed headers according to AWS CanonicalHeaders/SignedHeaders specifications.
  """
  @spec encode_headers(Keyword.t) :: {String.t, String.t}
  def encode_headers(headers) do
    sorted_headers = Enum.sort(headers, fn {k1, _}, {k2, _} -> k1 <= k2 end)
    encoded_headers = sorted_headers
      |> Enum.map(fn {k, v} -> "#{to_string(k) |> String.downcase}:#{String.strip(v)}" end)
      |> Enum.join("\n")
    signed_headers = sorted_headers
      |> Enum.map(fn {k, _} -> to_string(k) |> String.downcase end)
      |> Enum.join(";")
    {"#{encoded_headers}\n", signed_headers}
  end

  @doc """
  Encodes a payload according to AWS HashedPayload specifications.
  """
  @spec encode_payload(binary) :: String.t
  def encode_payload(nil), do: encode_payload("")
  def encode_payload(payload) do
    encode_hash_sha256(payload)
    |> encode_hex
  end


  ## String.Chars implementation

  defimpl String.Chars do
    def to_string(request = %CanonicalRequest{}) do
      [request.method,
       request.path,
       request.query,
       request.headers,
       request.signed_headers,
       request.payload]
      |> Enum.join("\n")
      |> IO.iodata_to_binary
    end
  end

end

