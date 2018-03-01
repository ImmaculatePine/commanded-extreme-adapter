ExUnit.start()

alias Commanded.EventStore.Adapters.Extreme

# configure this event store adapter for Commanded
Application.put_env(:commanded, :event_store_adapter, Extreme)
Application.put_env(:commanded, :stop_storage, &Extreme.Storage.stop/0)
Application.put_env(:commanded, :reset_storage, &Extreme.Storage.reset/0)
Application.put_env(:commanded, :event_store_wait, 10_000)
