defmodule AWSAuth.Encoding.DateTest do
  use ExUnit.Case
#  doctest AWSAuth.Encoding.Date

  import AWSAuth.Encoding.Date


  test "encoding numeric padded" do
    date = {2016, 4, 14}

    assert encode_numeric_padded(date) == "20160414"
  end

  test "encoding ISO 8601" do
    date = {2016, 4, 14}
    time = {8, 7, 3}

    assert encode_iso8601({date, time}) == "20160414T080703Z"
  end

end
