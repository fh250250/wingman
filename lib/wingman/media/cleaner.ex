defmodule Wingman.Media.Cleaner do
  @moduledoc """
  清扫器，周期性清除过期的分块与上传任务
  """

  # 执行周期
  @clean_interval 4 * 60 * 60 * 1000

  use GenServer

  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Media
  alias Wingman.Media.Upload

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    schedule_work()

    {:ok, :no_state}
  end

  @impl true
  def handle_info(:work, state) do
    clean()
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @clean_interval)
  end

  defp clean() do
    time = NaiveDateTime.utc_now() |> NaiveDateTime.add(-@clean_interval, :millisecond)
    query = from u in Upload, where: u.updated_at < ^time

    query
    |> Repo.all()
    |> Repo.preload(:chunks)
    |> Enum.each(&Media.delete_upload/1)
  end
end
