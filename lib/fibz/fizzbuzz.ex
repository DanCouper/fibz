defmodule Fibz.Fizzbuzz do
  @moduledoc """
  Convert integers according to the rules of FizzBuzz.
  'tis what it is.
  """

  @doc """
  Given an int, returns the corresponding fizz/buzz/fizzbuzz/int value.
  """
  @spec parse_int(integer) :: String.t() | integer
  def parse_int(i) when rem(i, 15) == 0, do: "fizzbuzz"
  def parse_int(i) when rem(i, 3) == 0, do: "fizz"
  def parse_int(i) when rem(i, 5) == 0, do: "buzz"
  def parse_int(i), do: i
end
