# Enux

utility package for loading, validating and documenting your app's configuration variables from env, json, jsonc and toml files at runtime and injecting them into your environment

## Installation

The package can be installed by adding `enux` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:enux, "~> 1.5"},

    # if you want to load `.jsonc` files, you should have this
    # you can also use this for `.json` files
    {:jsonc, "~> 0.9"},

    # if you want to load `.json` files, you should have either this
    {:euneus, "~> 1.2"}
    # or this
    {:jason, "~> 1.4"}
    # or this
    {:jaxon, "~> 2.0"}
    # or this
    {:jiffy, "~> 1.1"}
    # or this
    {:json, "~> 1.4"}
    # or this
    {:jsone, "~> 1.8"}
    # or this
    {:jsonrs, "~> 0.3"}
    # or this
    {:poison, "~> 5.0"}
    # or this
    {:thoas, "~> 1.2"}


    # if you want to load `.toml` files, you should have either this
    {:tomerl, "~> 0.5"}
    # or this
    {:toml, "~> 0.7"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/enux](https://hexdocs.pm/enux).
