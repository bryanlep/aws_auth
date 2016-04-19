defmodule AWSAuth.Encoding.Date do
  @moduledoc """
  Utilities for encoding date formats.
  """

  @doc """
  Encodes a date in numeric padded format: YYYYMMDD.
  """
  @spec encode_numeric_padded({integer, integer, integer}) :: String.t
  def encode_numeric_padded({year, month, day}) do
    [zero_pad(year, 4),
     zero_pad(month, 2),
     zero_pad(day, 2)]
    |> Enum.join("")
  end

  @doc """
  Encodes a date in ISO 8601 formatting.
  """
  @spec encode_iso8601({{integer, integer, integer}, {integer, integer, integer}}) :: String.t
  def encode_iso8601({{year, month, day}, {hour, minute, second}}) do
    [zero_pad(year, 4),
     zero_pad(month, 2),
     zero_pad(day, 2),
     "T",
     zero_pad(hour, 2),
     zero_pad(minute, 2),
     zero_pad(second, 2),
     "Z"]
    |> Enum.join("")
  end

  
  ## Helper functions

  @doc false
  @spec zero_pad(integer, integer) :: String
  defp zero_pad(integer, length) do
    Integer.to_string(integer)
    |> String.rjust(length, ?0)
  end

end
