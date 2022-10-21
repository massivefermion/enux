defmodule Enux do
  @moduledoc """
  utility package for loading, validating and documenting your app's configuration variables from env, json, jsonc and toml files at runtime and injecting them into your environment


  ## Installation

  ```
  defp deps do
    [
      {:enux, "~> 1.3"},

      # if you want to load `.jsonc` files, you should have this
      # you can also use this for `.json` files
      {:jsonc, "~> 0.8"},

      # if you want to load `.json` files, you should have either this
      {:json, "~> 1.4"}
      # or this
      {:jason, "~> 1.4"}
      # or this
      {:jaxon, "~> 2.0"}
      # or this
      {:thoas, "~> 0.4"}
      # or this
      {:jsone, "~> 1.7"}
      # or this
      {:jiffy, "~> 1.1"}
      # or this
      {:poison, "~> 5.0"}

      # if you want to load `.toml` files, you should have either this
      {:toml, "~> 0.6"}
      # or this
      {:tomerl, "~> 0.5"}
      # or this
      {:tomlex, "~> 0.0"}
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

  You should have either [poison](https://hex.pm/packages/poison) or [jason](https://hex.pm/packages/jason) or [jaxon](https://hex.pm/packages/jaxon)
  or [thoas](https://hex.pm/packages/thoas) or [jsone](https://hex.pm/packages/jsone) or [jiffy](https://hex.pm/packages/jiffy) or [json](https://hex.pm/packages/json)
  in your dependencies if you want to use `.json` files.

  To use `.jsonc` files, you should have [jsonc](https://hex.pm/packages/jsonc). You can also use this package for `.json` files.
  To use `.toml` files, you should have either [toml](https://hex.pm/packages/toml) or [tomerl](https://hex.pm/packages/tomerl) or [tomlex](https://hex.pm/packages/tomlex).

  You can load multiple files of different kinds:
  ```
  import Config

  env1 = Enux.load("config/one.env", url_encoded: true)
  config :otp_app, env1

  env2 = Enux.load("config/two.json")
  config :otp_app, :two, env2
  ```

  ### automatic loading

  Another way of using Enux is using the `Enux.autoload` function which will load all `.env`, `.json`, `.jsonc` and `.toml` files in your `config` directory.
  it makes more sense to call this function in your `config/runtime.exs` but you can call it anywhere in your code.

  If you have `config/pg.env` and `config/redis.json` in your project directory, after calling `Enux.autoload(:otp_app)`, you can access the variables
  using `Application.get_env(:otp_app, :pg)` and `Application.get_env(:otp_app, :redis)`. if a file is named `.env` or `.json` or `.jsonc` or `.toml`, you should use
  `Application.get_env(:otp_app, :env)` or `Application.get_env(:otp_app, :json)` or `Application.get_env(:otp_app, :jsonc)` or `Application.get_env(:otp_app, :toml)` respectively.
  ```
  Enux.autoload(:otp_app)
  ```

  ### multiple environments

  Using the `MIX_ENV` environmental variable you can adjust which files `Enux.autoload` loads into your app. If `MIX_ENV` is not specified, `dev` will be assumed.
  The only thing you need to do is specifying the environment in the name of each file like `db-staging.env`, `redis-prod.jsonc` or `rabbitmq-unit-tests.toml`.
  But after the file is loaded, you can access the variables using e.g. `Application.get_env(:otp_app, :db) or Application.get_env(:otp_app, :redis)` or
  `Application.get_env(:otp_app, :rabbitmq)`.
  If a file doesn't have `-` in its name, `Enux.autoload` will load it regardless of the value of `MIX_ENV`.

  ### environment validation

  You may also use `Enux.expect` to both validate and document your required environment. first you need to define a schema:
  ```
  schema = [
    id: [&is_integer/1, fn id -> id > 1000 end],
    username: [&is_binary/1, fn u -> String.length(u) > 8 end],
    metadata: [],
    profile: [
      full_name: [&is_binary/1],
      age: [&is_number/1]
    ]
  ]
  ```
  then the following line will check for compliance of your environment under `:otp_app` and `:key` with the schema defined above
  (an empty list implies only checking for existence):
  ```
  Enux.expect(:otp_app, :key, schema)
  ```
  """

  alias Enux.Env
  alias Enux.Json
  alias Enux.Jsonc
  alias Enux.Toml

  @doc """
  reads the variables in `config/.env` and returns a formatted keyword list.
  all values are loaded as they are.
  """
  def load() do
    File.stream!("config/.env", [], :line) |> Env.decode([])
  end

  @doc """
  reads the variables in `config/.env` and returns a formatted keyword list
  """
  def load(opts) when is_list(opts) do
    File.stream!("config/.env", [], :line) |> Env.decode(opts)
  end

  @doc """
  reads the variables in the given path(could be `.env`, `.json`, `.jsonc` or `.toml` file) and returns a formatted keyword list
  """
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    case String.split(path, ".") |> Enum.at(1) |> String.to_atom() do
      :env -> File.stream!(path, [], :line) |> Env.decode(opts)
      :json -> File.read!(path) |> Json.decode(opts)
      :jsonc -> File.read!(path) |> Jsonc.decode(opts)
      :toml -> File.read!(path) |> Toml.decode(opts)
      ext -> raise "unsupported file type: #{ext}"
    end
  end

  @doc """
  automatically loads all `.env`, `.json`, `.jsonc` and `.toml` files in your `config` directory.
  pass your project's name as an atom. you can also still pass `url_encoded: true` to it.
  """
  def autoload(app, opts \\ []) when is_atom(app) and is_list(opts) do
    files =
      File.ls!("config")
      |> Enum.map(fn f -> f |> String.split(".") end)
      |> Enum.filter(fn [_, ext] -> ext in ["env", "json", "jsonc", "toml"] end)
      |> Enum.filter(fn [filename, _] ->
        mix_env = System.get_env("MIX_ENV", "dev")

        case String.split(filename, "-") do
          [_] -> true
          [_, env] when env == mix_env -> true
          [_ | env_parts] -> Enum.join(env_parts, "-") == mix_env
        end
      end)
      |> Enum.map(fn f -> Enum.join(f, ".") end)

    cond do
      Enum.empty?(files) ->
        raise "There is no `.env`, `.json`, `.jsonc` or `.toml` file in your config directory"

      true ->
        files
        |> Enum.map(fn f -> [f, Enux.load("config/#{f}", opts)] end)
        |> Enum.map(fn [f, kwl] ->
          case f do
            ".env" ->
              ["env", kwl]

            ".json" ->
              ["json", kwl]

            ".jsonc" ->
              ["jsonc", kwl]

            ".toml" ->
              ["toml", kwl]

            _ ->
              [String.split(f, ".") |> Enum.at(0), kwl]
          end
        end)
        |> Enum.map(fn [key, kwl] ->
          case String.split(key, "-") do
            [key] -> [key, kwl]
            [key, _] -> [key, kwl]
            [key | _] -> [key, kwl]
          end
        end)
        |> Enum.each(fn [key, kwl] ->
          Application.put_env(app, String.to_atom(key), kwl)
        end)
    end
  end

  @doc """
  checks if the environment variables under `app` and `key` comply with the given `schema`. any non-compliance results in an error.
  you can use this function for both validating and documenting your required environment.
  """
  def expect(app, key, schema) when is_atom(app) and is_atom(key) and is_list(schema) do
    case Application.get_env(app, key) do
      nil ->
        raise "environment with key #{key} does not exist"

      env ->
        cond do
          Keyword.keyword?(env) ->
            if !Keyword.keyword?(schema) do
              raise "schema should be a keyword list"
            end

            check(env, schema)

          true ->
            check_item(env, schema, [])
        end
    end
  end

  defp check(env, schema, parents \\ [])
       when is_list(env) and is_list(schema) and is_list(parents) do
    Enum.each(schema, fn {key, sub_schema} ->
      case Keyword.get(env, key) do
        nil ->
          raise "your environment should contain #{parents |> Enum.reverse() |> Enum.join(".")}.#{key}"

        value ->
          cond do
            Keyword.keyword?(value) ->
              check(value, sub_schema, [key | parents])

            true ->
              check_item(value, sub_schema, [key | parents])
          end
      end
    end)
  end

  defp check_item(value, conditions, parents)
       when is_list(conditions) and is_list(parents) do
    Enum.each(conditions, fn c ->
      case check_item(value, c) do
        false ->
          raise "condition #{inspect(c)} was not met for #{parents |> Enum.reverse() |> Enum.join(".")}"

        true ->
          nil
      end
    end)
  end

  defp check_item(value, condition) when is_function(condition) do
    case condition.(value) do
      result when is_boolean(result) ->
        result

      _ ->
        raise "function #{inspect(condition)} does not return a boolean"
    end
  end
end
