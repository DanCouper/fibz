defmodule Fibz.Server do
  @moduledoc """
  The core of the Fibz application. A GenServer whose main function,
  `compute`, takes an integer and returns a computed value according
  to the rules of Fizzbuzz.

  Backed by an ETS table for caching.

  Registers a process group for the module to allow easy access to
  its functionality from remote nodes.
  """

  use GenServer

  alias Fibz.Fizzbuzz

  @fbserver __MODULE__

  @doc ~S"""
  Initialise the actual Fizbuzz server.

  1. Initialises state as an ETS table used as a naïve caching mechanism.
  2. Initilises and joins a process group with the same name as the module.

  ## Example

    iex> Fibz.Server.start_link([])
    ...> :pg2.which_groups
    [Fibz.Server]
  """
  def start_link(_arg) do
    GenServer.start_link(@fbserver, :ok, name: @fbserver)
  end

  @doc ~S"""
  Given an integer, compute the correct fizzbuzz return value.
  NOTE will hit the cache, and only actually run the computation
  if the value is not available.

  ## Example

      iex> Fibz.Server.start_link([])
      ...> Fibz.Server.compute(1)
      1
      iex> Fibz.Server.compute(3)
      "fizz"
      iex> Fibz.Server.compute(5)
      "buzz"
      iex> Fibz.Server.compute(15)
      "fizzbuzz"
  """
  def compute(int) do
    GenServer.call(@fbserver, {:compute, int})
  end

  @doc ~S"""
  Stops the server, normally.

  ## Example

      iex> Fibz.Server.start_link([])
      ...> Fibz.Server.stop
      :ok
  """
  def stop() do
    GenServer.stop(@fbserver)
  end

  ## CALLBACKS

  @impl true
  def init(:ok) do
    :pg2.create(@fbserver)
    :pg2.join(@fbserver, self())

    {:ok, :ets.new(@fbserver, [])}
  end

  @impl true
  def handle_call({:compute, int}, _from, cache) do
    case :ets.lookup(cache, int) do
      [] ->
        computed_val = Fizzbuzz.slow_parse_int(int)
        :ets.insert(cache, {int, computed_val})
        {:reply, computed_val, cache}

      [{_, v}] ->
        {:reply, v, cache}
    end
  end
end
