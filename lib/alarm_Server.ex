defmodule AlarmServer do
  use GenServer

  def init(pid) do
      {:ok, %{:eq => [], :al => [], :pid => pid}}
    end

  def handle_call({:register, infos}, _, state) do
    {:reply, :ok, Equipment.add(state, infos)}
  end

  def handle_call({:set_alarm, pid, name, filter_fun}, _, state) do
    {:reply, :ok, Alarm.add(state, [])}
  end

  def handle_call({:search, filter_fun}, _, state) do
    {:reply, {:ok, []}, state}
  end

  def handle_cast({:data, id, data}, state) do
    {:noreply, state}
  end



end
