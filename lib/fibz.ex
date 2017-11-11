defmodule Fibz do
  use Application

  @doc false
  def start(_type, _args) do
    Fibz.Supervisor.start_link()
  end
end
