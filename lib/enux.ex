defmodule Enux do
  @moduledoc """
  A package for reading variables from env style and json configuration files and injecting them into your application.

  ## Installation

  ```
  def deps do
    [
      {:enux, "~> 0.7.0"},

      # if you want to load json files, you should have either this
      {:jason, "~> 1.2"},
      # or this
      {:poison, "~> 4.0"}
    ]
  end
  ```
  ## Usage

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

  You should have either [poison](https://hex.pm/packages/poison) or [jason](https://hex.pm/packages/jason) in your dependencies if you want to use json files.

  You can load multiple files of different kinds:
  ```
  import Config

  env1 = Enux.load("config/one.env", url_encoded: true)
  config :otp_app, env1

  env2 = Enux.load("config/two.json")
  config :otp_app, env2
  ```
  """

  @doc """
  reads the variables in `config/.env` and returns a formatted keyword list.
  all values are loaded as they are.
  """
  def load() do
    File.stream!("config/.env", [], :line) |> Enux.Env.decode([])
  end

  @doc """
  reads the variables in `config/.env` and returns a formatted keyword list
  """
  def load(opts) when is_list(opts) do
    File.stream!("config/.env", [], :line) |> Enux.Env.decode(opts)
  end

  @doc """
  reads the variables in the given path(could be .env or .json file) and returns a formatted keyword list
  """
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    case String.split(path, ".") |> Enum.at(1) |> String.to_atom() do
      :env -> File.stream!(path, [], :line) |> Enux.Env.decode(opts)
      :json -> File.read!(path) |> Enux.Json.decode(opts)
      _ -> throw("unsupported file type")
    end
  end
end
