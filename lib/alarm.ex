defmodule Alarm do
  # Ajoute une alarme dans la liste des alarme
  def add(state, infos) do
    %{state | al: state.al ++ [infos]}
  end

  # Vérifie si un nom est déjà pris par une alarme
  # → retourne true si disponible, false sinon
  def available_name(infos, name) do
    case infos do
      [] -> true
      [head | tail] -> head[:name] != name and available_name(tail, name)
    end
  end

  # Vérifie si une alarme est déclenchée par les données reçues
  # Parcourt récursivement la liste d’alarmes
  def check_alarms(alarms, data) do
    case alarms do
      [] -> nil
      [head | tail] ->
        {id, infos} = data
        verif = head[:filter].(id, infos) # applique la fonction de filtre
        if verif do
          {head[:name], id, infos, head[:pid]} # alarme déclenchée
        else
          check_alarms(tail, data)             # sinon on continue
        end
    end
  end
end
