defmodule Equipment do
  @name :app

  def add(state, infos) do
    nil
  end

  def ping_data(id, data) do
    GenServer.cast(@name, {:data, id, data})
    Process.sleep(1000)
    ping_data(id, data)
  end

end
