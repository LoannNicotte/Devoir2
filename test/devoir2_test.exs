defmodule AlarmAppTest do
  use ExUnit.Case
  doctest AlarmApp

  setup do
    # Redémarre un nouveau serveur avant chaque test
    :ok = AlarmApp.start()
    :ok
  end

  test "on peut enregistrer un panneau solaire" do
    assert {:ok, id} = AlarmApp.register(:SolarPanel, %{surf: 2})
    assert is_integer(id)
  end

  test "enregistrement invalide renvoie une erreur" do
    assert {:error, _} = GenServer.call(:app, {:register, %{type: :Invalid}})
  end

  test "on peut rechercher un équipement" do
    {:ok, id1} = AlarmApp.register(:SolarPanel, %{surf: 2})
    {:ok, _id2} = AlarmApp.register(:SolarPanel, %{surf: 10})

    {:ok, ids} = AlarmApp.search(fn eq -> eq[:surf] == 2 end)
    assert ids == [id1]
  end

  test "ajout d'une alarme avec un nom unique" do
    assert {:ok, "alarm add"} =
             AlarmApp.set_alarm("temp_alarm", fn _, data -> data[:temp] > 35 end)
  end

  test "ajout d'une alarme avec un nom déjà utilisé renvoie une erreur" do
    assert {:ok, "alarm add"} =
             AlarmApp.set_alarm("temp_alarm", fn _, data -> data[:temp] > 35 end)

    assert {:error, "name already used"} =
             AlarmApp.set_alarm("temp_alarm", fn _, data -> data[:temp] > 40 end)
  end

  test "alarme déclenchée envoie un message" do
    {:ok, _id} = AlarmApp.register(:SolarPanel, %{surf: 20})
    AlarmApp.set_alarm("prod_alarm", fn _, data -> data[:prod] > 500 end)

    # on attend un message d'alarme (max 6 secondes)
    assert_receive {:alarm, "prod_alarm", _id, data}, 6000
    assert data[:prod] > 500
  end
end
