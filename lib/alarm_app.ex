defmodule AlarmApp do
  @name :app
  @server AlarmServer

  def start do
    GenServer.start(@server, nil, name: @name)
    :ok
  end

  def stop do
    GenServer.stop(@name, :stop)
  end
end
