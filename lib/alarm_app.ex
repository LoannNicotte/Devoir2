defmodule AlarmApp do
  @name :app

  @moduledoc """
  Application d'alarme :
  - :SolarPanel avec surf -> données (temp, prod)
  - :WindTurbine avec len -> données (rpm, prod)
  """

  # Démarre le GenServer AlarmServer
  def start() do
    GenServer.start_link(AlarmServer, nil, name: @name)
    :ok
  end

  # Arrête le serveur
  def stop do
    GenServer.stop(@name, :stop)
  end

  # Recherche d’équipements avec un filtre (fonctionnelle 4)
  def search(filter_fun) do
    GenServer.call(:app, {:search, filter_fun})
  end

  # Enregistre un nouvel équipement
  def register(type, infos) do
    GenServer.call(@name, {:register, Map.put(infos, :type, type)})
  end

  # Ajoute une alarme avec un nom et une fonction de filtre
  # → la pid qui reçoit les notifications est self()
  def set_alarm(name, filter_fun) do
    GenServer.call(@name, {:set_alarm, self(), name, filter_fun})
  end
end
