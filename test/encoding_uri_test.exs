defmodule AWSAuth.Encoding.URITest do
  use ExUnit.Case
#  doctest AWSAuth.Encoding.URI

  import AWSAuth.Encoding.URI

  test "unescaped characters" do
    Enum.each(?a..?z, &(assert char_unescaped?(&1) ))
    Enum.each(?A..?Z, &(assert char_unescaped?(&1) ))
    Enum.each(?0..?9, &(assert char_unescaped?(&1) ))
    Enum.each('-._~', &(assert char_unescaped?(&1) ))
    Enum.each(' /', &(refute char_unescaped?(&1)))
  end

  test "path encoding" do
    assert encode_path("/some/path") == "/some/path"
    assert encode_path("/some/path/with/sp ce") == "/some/path/with/sp%20ce"
  end

  test "uri component encoding" do
    assert encode_component("component/with/slash") == "component%2Fwith%2Fslash"
    assert encode_component("component~with-others._ !\"#$%&@") == "component~with-others._%20%21%22%23%24%25%26%40"
  end

end

