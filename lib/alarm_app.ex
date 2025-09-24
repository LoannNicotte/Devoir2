defmodule AlarmApp do
  @name :app
  @server AlarmServer

  def start(pid) do
    GenServer.start(@server, pid, name: @name)
    :ok
  end

  def stop do
    GenServer.stop(@name, :stop)
  end

  def register(data) do
    GenServer.call(@name, {:register, data})
  end
end
