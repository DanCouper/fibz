defmodule Fibz do
  @moduledoc """
  1. Fibz wraps a GenServer which accepts a `call`, taking an integer
     and returning fizz, buzz or fizzbuzz (according to
     the normal rules of fizzbuzz) - `Fibz.compute(int)`

  2. Sending a `:stop` cast message will cause `Fibz.Server` to exit normally;
     this is triggered by `Fibz.stop`.
     NOTE this would work without any kind of explicit function - simply
     casting a `:stop` message to the server will automatically do that, this
     just makes the API a little more explicit.
     FIXME `stop` has been used rather than `cast`

  3. `Fibz.Server` restarts automatically after crashing or receiving
     the `:stop` cast message (i.e. `restart` is set to the default `:permanent`).

  4. Fibs stores calculated fizz buzzes in an ETS table (the server state, a cache).
     It checks the cache prior to calculating.
     NOTE the actual function used to calculate Fizzbuzz is artificially slowed
     using `Process.sleep` to simulate computation - this makes it clear in the
     console when there is a cache hit or a cache miss.

  5. Fibz broadcasts its existence via :pg2. A group with the same name as the server
     is created on init, and any node connecting to the server node will be able to
     join that group then run Fibz functions as normal.
     NOTE no broadcasting functionality has been included, it simply allows access
     to the functionality. A simple visual demonstartion of it working is to run
     a compute function on a remote node, then run same again on either master or
     a second remote node - the cache will be hit, the value will not be recomputed.
  """

  use Application

  @doc false
  def start(_type, _args) do
    Fibz.Supervisor.start_link()
  end
end
