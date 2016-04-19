defmodule AWSAuth.CredentialsTest do
  use ExUnit.Case
#  doctest AWSAuth.Credentials

  alias AWSAuth.Credentials


  test "serialization" do
    datetime = {{2016, 4, 14}, {13, 23, 57}}

    credentials = %Credentials{access_key: "ACCESS_KEY",
                               secret_key: "SECRET_KEY",
                               datetime: datetime,
                               region: "region",
                               service: "service"}

    assert Credentials.scope(credentials) == "20160414/region/service/aws4_request"
    assert "#{credentials}" == "ACCESS_KEY/20160414/region/service/aws4_request"
  end

end
