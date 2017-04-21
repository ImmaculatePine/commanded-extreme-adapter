defmodule Commanded.EventStore.Adapters.Extreme.ResetStorage do
  def execute do
    Application.ensure_all_started(:extreme)

  	reset_extreme_storage()

  	Application.stop(:extreme)
  	Application.ensure_all_started(:extreme)
  end

  defp reset_extreme_storage do
    server = %{
      baseUrl: "http://localhost:2375",
      ssl_options: [
      	{:certfile, 'docker.crt'},
      	{:keyfile, 'docker.key'},
      ]
    }
    container_name = "commanded-tests-eventstore"

    {:ok, conn} = Docker.start_link server

    Docker.Container.kill conn, container_name
    Docker.Container.delete conn, container_name
    Docker.Container.create conn, container_name, %{
      "Image": "eventstore/eventstore",
      "ExposedPorts": %{
      	"2113/tcp" => %{},
      	"1113/tcp" => %{}
      },
      "PortBindings": %{
      	"1113/tcp": [%{ "HostPort" => "1113" }],
      	"2113/tcp": [%{ "HostPort" => "2113" }]
      },
      "Env": [
      	"EVENTSTORE_DB=/tmp/db",
      	"EVENTSTORE_RUN_PROJECTIONS=All",
      	"EVENTSTORE_START_STANDARD_PROJECTIONS=True"
      ]
    }

    Docker.Container.start conn, container_name

    wait_eventstore_ready()
  end

  defp wait_eventstore_ready do
    headers = ["Accept": "application/vnd.eventstore.atom+json"]
    options = [recv_timeout: 400]

    case HTTPoison.get "http://localhost:2113/streams/somestream", headers, options do
      {:ok, %HTTPoison.Response{status_code: 404}} ->
      	:timer.sleep(400)
      	:ok

      _ ->
      	:timer.sleep(400)
      	wait_eventstore_ready()
    end
  end
end
