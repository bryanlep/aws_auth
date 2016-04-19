defmodule AWSAuth.Credentials do
  @moduledoc """
  AWS request credential information.
  """
  
  alias __MODULE__
  import AWSAuth.Encoding.Date


  defstruct [:access_key, :secret_key, :datetime, :region, :service]


  @type t :: %Credentials{access_key: String.t,
                          secret_key: String.t,
                          datetime: datetime,
                          region: String.t,
                          service: String.t}
  @type datetime :: {date, time}
  @type date :: {integer, integer, integer}
  @type time :: {integer, integer, integer}


  @doc """
  Returns the scope string of the credential.
  """
  def scope(credentials = %Credentials{}) do
    {date, _} = credentials.datetime

    [encode_numeric_padded(date),
     credentials.region,
     credentials.service,
     "aws4_request"]
    |> Enum.join("/")
  end


  ## String.Chars implementation

  defimpl String.Chars do
    def to_string(credentials = %Credentials{}) do
      [credentials.access_key, Credentials.scope(credentials)]
      |> Enum.join("/")
    end
  end

end
