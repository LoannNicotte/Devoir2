defmodule AlarmServer do
  use GenServer
  @equipment [:SolarPanel, :WindTurbine]

  # Initialisation : état vide
  def init(_) do
    {:ok, %{eq: [], al: [], data: []}}
  end

  # ----- Fonctionnalité 1 : register -----
  def handle_call({:register, infos}, _, state) do
    cond do
      # Vérification du type
      infos.type not in @equipment ->
        {:reply, {:error, "type invalid"}, state}

      # Vérification des données pour un panneau solaire
      infos.type == :SolarPanel and not(Map.has_key?(infos, :surf) and is_number(infos[:surf])) ->
        {:reply, {:error, "invalid data for surface"}, state}

      # Vérification des données pour une éolienne
      infos.type == :WindTurbine and not(Map.has_key?(infos, :len) and is_number(infos[:len])) ->
        {:reply, {:error, "invalid data for length"}, state}

      # Tout est bon → ajout dans la liste des équipements
      true ->
        {n_state, id} = Equipment.add(state, infos)
        {:reply, {:ok, id}, n_state}
    end
  end

  # ----- Fonctionnalité 3 : set_alarm -----
  def handle_call({:set_alarm, pid, name, filter_fun}, _, state) do
    if Alarm.available_name(state.al, name) do
      {:reply, {:ok, "alarm add"},
       Alarm.add(state, %{name: name, filter: filter_fun, pid: pid})}
    else
      {:reply, {:error, "name already used"}, state}
    end
  end

  # ----- Fonctionnalité 4 : search -----
  def handle_call({:search, filter_fun}, _, state) do
    {:reply, {:ok, Equipment.search_ids(state.eq, filter_fun)}, state}
  end


  # ----- Fonctionnalité 2 : réception de données -----
  def handle_cast({:data, id, data}, state) do
    # Vérifie si une alarme doit être déclenchée
    alarm = Alarm.check_alarms(state[:al], {id, data})
    if alarm != nil do
      {name, id, data, pid} = alarm
      send(pid, {:alarm, name, id, data})
    end

    # Mise à jour des données en mémoire
    {:noreply, Equipment.add_data(state, id, data)}
  end
end
