defmodule FibzTest do
  use ExUnit.Case
  doctest Fibz

  test "greets the world" do
    assert Fibz.hello() == :world
  end
end
