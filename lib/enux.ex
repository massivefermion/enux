defmodule Enux do
  @moduledoc """
  A package for reading variables from env style and json configuration files and injecting them into your application.

  ## Installation

  ```
  def deps do
    [
      {:enux, "~> 0.8.0"},

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

  You should have either [poison](https://hex.pm/packages/poison) or [jason](https://hex.pm/packages/jason)
  in your dependencies if you want to use json files.

  You can load multiple files of different kinds:
  ```
  import Config

  env1 = Enux.load("config/one.env", url_encoded: true)
  config :otp_app, env1

  env2 = Enux.load("config/two.json")
  config :otp_app, :two, env2
  ```

  Another way of using Enux is using the `Enux.autoload` function which will load all `.env` and `.json` files in your `config` directory.
  it makes more sense to call this function in your `config/runtime.exs` but you can call it anywhere in your code.

  If you have `config/pg.env` and `config/redis.json` in your project directory, after calling `Enux.autoload(:otp_app)`, you can access the variables
  using `Application.get_env(:otp_app, :pg)` and `Application.get_env(:otp_app, :redis)`. if a file is named `.env` or `.json`, you should use
  `Application.get_env(:otp_app, :env)` or `Application.get_env(:otp_app, :json)` respectively.
  ```
  Enux.autoload(:otp_app)
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
  reads the variables in the given path(could be `.env` or `.json` file) and returns a formatted keyword list
  """
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    case String.split(path, ".") |> Enum.at(1) |> String.to_atom() do
      :env -> File.stream!(path, [], :line) |> Enux.Env.decode(opts)
      :json -> File.read!(path) |> Enux.Json.decode(opts)
      _ -> throw("unsupported file type")
    end
  end

  @doc """
  automatically loads all `.env` and `.json` files in your `config` directory.
  pass your projects name as an atom. you can also still pass `url_encoded: true` to it.
  """
  def autoload(otp_app, opts \\ []) when is_atom(otp_app) and is_list(opts) do
    files =
      File.ls!("config")
      |> Enum.map(fn f -> f |> String.split(".") end)
      |> Enum.filter(fn [_, ext] -> ext in ["json", "env"] end)
      |> Enum.map(fn f -> Enum.join(f, ".") end)

    cond do
      Enum.empty?(files) ->
        throw("There is no .env or .json file in your config directory")

      true ->
        files
        |> Enum.map(fn f -> [f, Enux.load("config/#{f}", opts)] end)
        |> Enum.each(fn [f, kwl] ->
          key =
            case f do
              ".env" ->
                :env

              ".json" ->
                :json

              _ ->
                String.split(f, ".") |> Enum.at(0) |> String.to_atom()
            end

          Application.put_env(otp_app, key, kwl)
        end)
    end
  end
end
