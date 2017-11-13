defmodule Fibz.FizzbuzzServer do
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

    iex> Fibz.FizzbuzzServer.start_link([])
    ...> :pg2.which_groups
    [Fibz.FizzbuzzServer]
  """
  def start_link(_arg) do
    GenServer.start_link(@fbserver, :ok, name: @fbserver)
  end

  @doc ~S"""
  Stops the server, normally.
  NOTE Normally would be a seperate function off; using the same
  function call as the one used to actually do computation seems wrong,
  but it simplifies the task a little.

  ## Example

      iex> Fibz.FizzbuzzServer.start_link([])
      ...> Fibz.FizzbuzzServer.compute(:stop)
      :ok
  """
  def compute(:stop) do
    GenServer.cast(@fbserver, :stop)
  end

  @doc ~S"""
  Given an integer, compute the correct fizzbuzz return value.
  NOTE will hit the cache, and only actually run the computation
  if the value is not available.

  ## Example

      iex> Fibz.FizzbuzzServer.start_link([])
      ...> Fibz.FizzbuzzServer.compute(1)
      1
      iex> Fibz.FizzbuzzServer.compute(3)
      "fizz"
      iex> Fibz.FizzbuzzServer.compute(5)
      "buzz"
      iex> Fibz.FizzbuzzServer.compute(15)
      "fizzbuzz"
  """
  def compute(int) do
    GenServer.call(@fbserver, {:compute, int})
  end

  @doc """
  NOTE: Used only for visual debugging: given a message [from an external node], leverages a
  `handle_info` callback to broadcast the message to interested parties (any Fizzbuzz servers).
  """
  def broadcast(message) do
    for pid <- :pg2.get_members(@fbserver) do
      send(pid, message)
    end
  end

  ## CALLBACKS

  @impl true
  def init(:ok) do
    :pg2.create(@fbserver)
    :pg2.join(@fbserver, self())

    {:ok, :ets.new(@fbserver, [])}
  end

  @impl true
  def handle_call({:compute, int}, from, cache) do
    case :ets.lookup(cache, int) do
      [] ->
        computed_val = Fizzbuzz.slow_parse_int(int)
        :ets.insert(cache, {int, computed_val})
        broadcast({from, "Value of '#{computed_val}' computed using Fibz' Fizzbuzz server via a call from node #{inspect from}"})
        {:reply, computed_val, cache}

      [{_, v}] ->
        broadcast({from, "Value of '#{v}' pulled from cache using Fibz' Fizzbuzz server via a call from node #{inspect from}"})
        {:reply, v, cache}
    end
  end

  @impl true
  def handle_cast(:stop, cache) do
    broadcast({:stop_server, ":stop message cast to Fibz' Fizzbuzz server. Cache cleared down, server restarted."})
    :pg2.leave(@fbserver, self())
    {:noreply, :ets.delete_all_objects(cache)}
  end

  @impl true
  def handle_info({:stop_server, message}, state) do
    IO.inspect(message)
    {:noreply, state}
  end

  @impl true
  def handle_info({_pid, message}, state) do
    IO.inspect(message)
    {:noreply, state}
  end
end
