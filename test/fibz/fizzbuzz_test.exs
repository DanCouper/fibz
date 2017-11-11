defmodule Fibz.FizzbuzzTest do
  use ExUnit.Case, async: true
  use ExUnitProperties, async: true
  alias Fibz.Fizzbuzz

  # Contrived example but ¯\_(ツ)_/¯
  property "parse_int/1" do
    check all n <- StreamData.integer() do
      cond do
        rem(n, 15) == 0 -> assert Fizzbuzz.parse_int(n) == "fizzbuzz"
        rem(n, 5) == 0 -> assert Fizzbuzz.parse_int(n) == "buzz"
        rem(n, 3) == 0 -> assert Fizzbuzz.parse_int(n) == "fizz"
        true -> assert Fizzbuzz.parse_int(n) == n
      end
    end
  end
end
