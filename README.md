# AlarmApp

AlarmApp est une petite application Elixir simulant un système de gestion
d'équipements (panneaux solaires, éoliennes) et d'alarmes associées.

---

## Fonctionnalités

1. **Enregistrement d'équipements**
   - Deux types seulement sont implémentés :
     - **Panneau solaire** (`:SolarPanel`) avec une **surface** (`:surf`, nombre ≥ 1)
     - **Éolienne** (`:WindTurbine`) avec une **longueur de pale** (`:len`, nombre ≥ 1)
   - Chaque type a besoin **au minimum d’une info** (`:surf` ou `:len`) pour être valide.
   - Chaque équipement reçoit un identifiant unique (`id`).

2. **Simulation de données**
   - Chaque équipement génère automatiquement **2 valeurs** toutes les 5 secondes :
     - **SolarPanel** → température (`temp`) et production (`prod`)
     - **WindTurbine** → vitesse de rotation (`rpm`) et production (`prod`)

3. **Alarmes**
   - Possibilité de définir une alarme avec :
     - un nom unique
     - une fonction de filtre `(id, data) -> true/false`
     - le `pid` du process qui recevra les notifications
   - Lorsqu'une alarme est déclenchée, un message est envoyé :
     ```elixir
     {:alarm, name, id, data}
     ```

4. **Recherche**
   - Permet de rechercher des équipements selon un filtre :
     ```elixir
     AlarmApp.search(fn eq -> eq[:surf] > 5 end)
     # → retourne les IDs correspondant
     ```

---

## Lancer le projet

1. Lance la console :
   ```bash
   iex -S mix
   ```

2. Démarre l'application :
   ```elixir
   AlarmApp.start()
   ```

---

## Exemples d'utilisation

### Enregistrer des équipements
```elixir
{:ok, id1} = AlarmApp.register(:SolarPanel, %{surf: 2})
{:ok, id2} = AlarmApp.register(:WindTurbine, %{len: 10})
```

### Définir une alarme
```elixir
AlarmApp.set_alarm("high_temp", fn _, data -> data[:temp] > 32 end)
```

### Réceptionner les alarmes
```elixir
receive do
  {:alarm, name, id, data} ->
    IO.puts("ALARME #{name} déclenchée par équipement #{id} → #{inspect(data)}")
end
```

### Rechercher des équipements
```elixir
AlarmApp.search(fn eq -> eq[:type] == :SolarPanel and eq[:surf] > 1 end)
# => [id1]
```

---

## Exemple complet

```elixir
AlarmApp.start()

# Ajout d'équipements
{:ok, id1} = AlarmApp.register(:SolarPanel, %{surf: 1})
{:ok, id2} = AlarmApp.register(:SolarPanel, %{surf: 10})
{:ok, id3} = AlarmApp.register(:WindTurbine, %{len: 5})

# Alarme sur la température
AlarmApp.set_alarm("high_temp", fn _, data -> data[:temp] > 32 end)

# Attente d'une alarme
receive do
  {:alarm, name, id, data} ->
    IO.puts("ALARME #{name} sur équipement #{id} : #{inspect(data)}")
after
  10_000 ->
    IO.puts("Pas d'alarme déclenchée dans les 10 secondes")
end

# Recherche
AlarmApp.search(fn eq -> eq[:type] == :SolarPanel and eq[:surf] >= 10 end)
# => [id2]
```

---
