defmodule Fibz do
  use Application

  @doc false
  def start(_type, _args) do
    Fibz.Supervisor.start_link()
  end

  @doc ~S"""
  Given an integer, compute the correct fizzbuzz return value.
  NOTE will hit the cache, and only actually run the computation
  if the value is not available.

  ## Example

      iex> Application.start(Fibz, [])
      ...> Fibz.compute(1)
      1
      iex> Fibz.compute(3)
      "fizz"
      iex> Fibz.compute(5)
      "buzz"
      iex> Fibz.compute(15)
      "fizzbuzz"
  """
  defdelegate compute(int), to: Fibz.Server

  @doc ~S"""
  Stops the server, normally.

  ## Example

      iex> Application.start(Fibz, [])
      ...> Fibz.stop_compute_server
      :ok
  """
  defdelegate stop_compute_server, to: Fibz.Server, as: :stop
end
