defmodule MixApp1Test do
  use ExUnit.Case
  doctest MixApp1

  test "greets the world" do
    assert MixApp1.hello() == :world
  end
end
