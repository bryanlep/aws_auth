defmodule AWSAuth.Encoding.URI do
  @moduledoc """
  Utilities for encoding URI components according to AWS specifications.
  """

  @doc """
  Encodes a uri path.
  """
  @spec encode_path(String.t) :: String.t
  def encode_path(path) do
    URI.encode(path, &( &1 == ?/ or char_unescaped?(&1)))
  end
  
  @doc """
  Encodes a uri component.
  """
  @spec encode_component(String.t | atom | nil) :: String.t
  def encode_component(nil), do: ""
  def encode_component(atom) when is_atom(atom),
    do: to_string(atom) |> encode_component
  def encode_component(component) do
    URI.encode(component, &char_unescaped?/1)
  end

  @doc """
  Whether the character is allowed unescaped when encoding.
  """
  @spec char_unescaped?(char) :: boolean
  def char_unescaped?(c) do
    c in ?a..?z or
    c in ?A..?Z or
    c in ?0..?9 or
    c in '-._~'
  end

end
