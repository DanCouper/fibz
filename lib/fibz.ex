defmodule Fibz do
  @moduledoc """
  1. Fibz wraps a GenServer which accepts a `call`, taking an integer
     and returning fizz, buzz or fizzbuzz (according to
     the normal rules of fizzbuzz) - `Fibz.compute(int)`

  2. Sending a `:stop` cast message will cause `Fibz.Server` to exit normally;
     this is triggered by `Fibz.stop_compute_server`.
     FIXME `stop` has been used rather than `cast`

  3. `Fibz.Server` restarts automatically after crashing or receiving
     the `:stop` cast message (i.e. `restart` is set to the default `:permanent`).

  4. Fibs stores calculated fizz buzzes in an ETS table (the server state, a cache).
     It checks the cache prior to calculating.

  5. TODO Fibz broadcasts its existence via :pg2, and you should be able to
     demonstrate connecting remotely to the running application (from say the Elixir REPL)
     and sending messages to the GenServer process.
  """

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
