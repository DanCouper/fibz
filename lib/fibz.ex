defmodule Fibz do
  @moduledoc """
  1. Fibz wraps a GenServer which accepts a `call`, taking an integer
     and returning fizz, buzz or fizzbuzz (according to
     the normal rules of fizzbuzz) - `Fibz.FizzbuzzServer.compute(int)`

  2. Sending a `:stop` cast message will cause `Fibz.Server` to exit normally;
     this is triggered by `Fibz.FizzbuzzServer.compute(:stop)`.

  3. `Fibz.FizzbuzzServer` restarts automatically after crashing or receiving
     the `:stop` cast message (i.e. `restart` is set to the default `:permanent`).

  4. Fibs stores calculated fizz buzzes in an ETS table (the server state, a cache).
     It checks the cache prior to calculating.
     NOTE the actual function used to calculate Fizzbuzz is artificially slowed
     using `Process.sleep` to simulate computation - this makes it clear in the
     console when there is a cache hit or a cache miss.

  5. Fibz broadcasts its existence via :pg2. A group with the same name as the server
     is created on init, and any node connecting to the server node will be able to
     join that group then run Fibz functions as normal.
     NOTE a fragile, naïve broadcast implementation has been included in the server that
     uses IO.inspect to print messages to the console, relying on the process group
  """

  use Application

  @doc false
  def start(_type, _args) do
    Fibz.Supervisor.start_link()
  end
end
