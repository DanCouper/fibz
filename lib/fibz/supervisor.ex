defmodule Fibz.Supervisor do
  @moduledoc false
  use Supervisor

  @fbsupervisor __MODULE__

  def start_link do
    Supervisor.start_link(@fbsupervisor, :ok, name: @fbsupervisor)
  end

  def init(:ok) do
    children = [
      Fibz.Server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
