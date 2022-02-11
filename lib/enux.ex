defmodule Enux do
  @moduledoc """
  utility package for loading, validating and documenting your app's configuration variables from env, json and jsonc files at runtime and injecting them into your environment


  ## Installation

  ```
  defp deps do
    [
      {:enux, "~> 1.0.4"},

      # if you want to load `.jsonc` files, you should have this
      # you can also use this for `.json` files
      {:jsonc, "~> 0.2"},

      # if you want to load `.json` files, you should have either this
      {:jason, "~> 1.3"}
      # or this
      {:poison, "~> 5.0"}
      # or this
      {:jaxon, "~> 2.0"}
      # or this
      {:thoas, "~> 0.2"}
      # or this
      {:jsone, "~> 1.7"}
      # or this
      {:jiffy, "~> 1.0"}
      # or this
      {:json, "~> 1.4"}
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

  You can load multiple files of different kinds:
  ```
  import Config

  env1 = Enux.load("config/one.env", url_encoded: true)
  config :otp_app, env1

  env2 = Enux.load("config/two.json")
  config :otp_app, :two, env2
  ```

  Another way of using Enux is using the `Enux.autoload` function which will load all `.env`, `.json` and `.jsonc` files in your `config` directory.
  it makes more sense to call this function in your `config/runtime.exs` but you can call it anywhere in your code.

  If you have `config/pg.env` and `config/redis.json` in your project directory, after calling `Enux.autoload(:otp_app)`, you can access the variables
  using `Application.get_env(:otp_app, :pg)` and `Application.get_env(:otp_app, :redis)`. if a file is named `.env` or `.json` or `.jsonc`, you should use
  `Application.get_env(:otp_app, :env)` or `Application.get_env(:otp_app, :json)` or `Application.get_env(:otp_app, :jsonc)` respectively.
  ```
  Enux.autoload(:otp_app)
  ```

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
  reads the variables in the given path(could be `.env` or `.json` or `.jsonc` file) and returns a formatted keyword list
  """
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    case String.split(path, ".") |> Enum.at(1) |> String.to_atom() do
      :env -> File.stream!(path, [], :line) |> Env.decode(opts)
      :json -> File.read!(path) |> Json.decode(opts)
      :jsonc -> File.read!(path) |> Jsonc.decode(opts)
      ext -> raise "unsupported file type: #{ext}"
    end
  end

  @doc """
  automatically loads all `.env`, `.json` and `.jsonc` files in your `config` directory.
  pass your project's name as an atom. you can also still pass `url_encoded: true` to it.
  """
  def autoload(app, opts \\ []) when is_atom(app) and is_list(opts) do
    files =
      File.ls!("config")
      |> Enum.map(fn f -> f |> String.split(".") end)
      |> Enum.filter(fn [_, ext] -> ext in ["env", "json", "jsonc"] end)
      |> Enum.map(fn f -> Enum.join(f, ".") end)

    cond do
      Enum.empty?(files) ->
        raise "There is no `.env` or `.json` or `.jsonc` file in your config directory"

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

              ".jsonc" ->
                :jsonc

              _ ->
                String.split(f, ".") |> Enum.at(0) |> String.to_atom()
            end

          Application.put_env(app, key, kwl)
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
    schema
    |> Enum.each(fn {key, sub_schema} ->
      case env |> Keyword.get(key) do
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
    conditions
    |> Enum.each(fn c ->
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
