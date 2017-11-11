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

  @doc """
  Identical to `parse_int`, but with a delay to imitate a computationally
  intensive/external network call. Fizbuzz is most definitely not
  computationally expensive; `slow_parse_int` allows a naïve comparison
  between cache hits with tiny overhead, and cache misses, when this
  function will actually run.
  """
  @spec slow_parse_int(integer) :: String.t() | integer
  def slow_parse_int(i) do
    Process.sleep(:rand.uniform(350))
    parse_int(i)
  end
end
