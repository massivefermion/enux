defmodule Enux do
  @moduledoc """
  A module for reading variables from .env style configuration files and injecting them into your application.

  In elixir 1.11, `config/runtime.exs` was introduced. This is a file that is executed exactly before your application starts.
  This is a proper place to load any configuration variables into your app. If this file does not exist in your project directory,
  create it and add these lines to it:
  ```
  import Config
  env = Enux.load()
  config :otp_app, env
  ```
  When you start your application, you can access your configuration variables using `Applicatoin.get_env`.
  If you need to url encode your configuration values, just pass `url_encoded: true` to `Enux.load`.
  """

  @doc """
  reads the variables in `config/.env` and returns a formatted keyword list.
  all values are loaded as they are.
  """
  def load() do
    File.stream!("config/.env", [], :line) |> pipeline([])
  end

  @doc """
  reads the variables in `config/.env` and returns a formatted keyword list
  """
  def load(opts) when is_list(opts) do
    File.stream!("config/.env", [], :line) |> pipeline(opts)
  end

  @doc """
  reads the variables in the given path and returns a formatted keyword list
  """
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    File.stream!(path, [], :line) |> pipeline(opts)
  end

  defp pipeline(content, opts) do
    content
    |> IO.inspect()
    |> Enum.filter(fn l -> String.trim(l) != "" end)
    |> IO.inspect()
    |> Enum.map(fn l ->
      Regex.run(~r/(?<k>[A-Za-z0-9_\s]+)=(?<v>.*)/, l, capture: :all_but_first)
    end)
    |> IO.inspect()
    |> Enum.map(fn l -> l |> Enum.map(fn i -> String.trim(i) end) end)
    |> IO.inspect()
    |> Enum.map(fn [k, v] ->
      {k |> handle_number() |> String.to_atom(), v |> url_encode_conditional(opts)}
    end)
  end

  defp url_encode_conditional(value, opts) when is_binary(value) and is_list(opts) do
    case opts |> Keyword.get(:url_encoded, false) do
      true -> value |> URI.encode()
      false -> value
    end
  end

  defp handle_number(key) when is_binary(key) do
    case key |> String.first() |> Integer.parse() do
      {_, ""} -> throw("#{key} starts with a digit")
      :error -> key
    end
  end
end
