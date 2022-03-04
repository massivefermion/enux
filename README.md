# Enux

utility package for loading, validating and documenting your app's configuration variables from env, json, jsonc and toml files at runtime and injecting them into your environment

## Installation

The package can be installed by adding `enux` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:enux, "~> 1.2.0"},

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
    {:jiffy, "~> 1.1"}
    # or this
    {:json, "~> 1.4"}


    # if you want to load `.toml` files, you should have either this
    {:toml, "~> 0.6.2"}
    # or this
    {:tomerl, "~> 0.5.0"}
    # or this
    {:tomlex, "~> 0.0.5"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/enux](https://hexdocs.pm/enux).
