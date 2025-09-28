defmodule Equipment do
  @name :app

  # Ajoute un équipement et démarre son envoi périodique de données
  def add(state, infos) do
    id = get_max_id(state[:eq])
    spawn(Equipment, :ping_data, [id, infos])
    {%{state | eq: state.eq ++ [Map.put(infos, :id, id)]}, id}
  end

  # Simule l’envoi de données aléatoires toutes les 5 secondes
  def ping_data(id, infos) do
    GenServer.cast(@name, {:data, id, random_data(infos)})
    Process.sleep(5000)
    ping_data(id, infos) # récursion infinie
  end

  # Ajoute une donnée reçue dans l’état (historique)
  def add_data(state, id, data) do
    %{state | data: state.data ++ [{id, data}]}
  end

  # Recherche récursive des IDs correspondant à un filtre (fonctionnalité 4)
  def search_ids(equipment, fun) do
    case equipment do
      [] -> []
      [eq | tail] ->
        if fun.(eq) do
          [eq.id | search_ids(tail, fun)]
        else
          search_ids(tail, fun)
        end
    end
  end

  # Donne le prochain ID disponible
  def get_max_id(infos) do
    case infos do
      [] -> 0
      [head | tail] -> max(head[:id] + 1, get_max_id(tail))
    end
  end

  # Génère des données aléatoires selon le type d’équipement
  def random_data(infos) do
    case infos.type do
      :SolarPanel ->
        %{temp: normal(30, 3), prod: normal(180 * infos[:surf], 18 * infos[:surf])}

      :WindTurbine ->
        %{rpm: normal(200, 20) / infos[:len],
          prod: normal(50, 5) * infos[:len] * infos[:len]}
    end
  end

  # Générateur de nombres suivant une loi normale (Box–Muller)
  def normal(mu \\ 0.0, sigma \\ 1.0) do
    u1 = :rand.uniform()
    u2 = :rand.uniform()
    z0 = :math.sqrt(-2.0 * :math.log(u1)) * :math.cos(2.0 * :math.pi() * u2)
    mu + sigma * z0
  end
end
