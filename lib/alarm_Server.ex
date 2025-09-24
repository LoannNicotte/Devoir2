defmodule AlarmServer do
  use GenServer

  def init(_) do
      {:ok, []}
    end

  def handle_call({:register, infos}, _, state) do
    {:reply, :ok, Equipment.add(state, infos)}
  end

  def handle_cast({:data, id, data}, state) do

  end


end
