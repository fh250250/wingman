defmodule Wingman.Storage do
  @moduledoc """
  存储库
  """

  @storage_config Application.get_env(:wingman, Wingman.Storage)

  @doc """
  创建初始的存储目录
  """
  def setup do
    File.mkdir_p!(@storage_config[:root_path])
    File.mkdir_p!(@storage_config[:tmp_path])
  end

  @doc """
  列出文件与目录
  """
  def ls(path) do
    with {:ok, dir} <- safe_path(path),
         {:ok, files} <- File.ls(dir)
    do
      items =
        files
        |> Enum.map(fn filename ->
          abs_path = Path.expand(filename, dir)
          relative_path = Path.relative_to(abs_path, @storage_config[:root_path])

          {relative_path, File.stat(abs_path)}
        end)
        |> Enum.filter(&match?({_relative_path, {:ok, _stat}}, &1))
        |> Enum.map(fn {relative_path, {:ok, stat}} ->
          %{path: relative_path,
            type: stat.type,
            size: stat.size}
        end)

      {:ok, items}
    end
  end

  @doc """
  创建目录
  """
  def mkdir(path) do
    with {:ok, dir} <- safe_path(path) do
      File.mkdir(dir)
    end
  end

  @doc """
  保存上传的文件
  """
  def save_file(path, %Plug.Upload{filename: filename, path: filepath}) do
    with {:ok, dir} <- safe_path(path),
         {:ok, destpath} <- build_destpath(dir, filename)
    do
      File.rename(filepath, destpath)
    end
  end

  @doc """
  移动或重命名文件与目录
  """
  def rename(source, dest) do
    with {:ok, sourcepath} <- safe_path(source),
         {:ok, destpath} <- safe_path(dest)
    do
      File.rename(sourcepath, destpath)
    end
  end




  ### Private

  # 确保路径被限制在存储目录中
  defp safe_path(path) do
    abs_path = Path.expand(path, @storage_config[:root_path])

    if String.starts_with?(abs_path, @storage_config[:root_path]) do
      {:ok, abs_path}
    else
      {:error, "非法路径"}
    end
  end

  # 根据目录与文件名构造路径
  defp build_destpath(dir, filename) do
    with {:ok, path} <- Path.join(dir, filename) |> safe_path() do
      destpath =
        if File.exists?(path) do
          Path.rootname(path) <> "_" <> random_string(8) <> Path.extname(path)
        else
          path
        end

      {:ok, destpath}
    end
  end

  defp random_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
