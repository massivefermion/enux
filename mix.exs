defmodule Enux.MixProject do
  use Mix.Project

  @source_url "https://github.com/massivefermion/enux"

  def project do
    [
      app: :enux,
      version: "1.1.3",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp description do
    "utility package for loading, validating and documenting your app's configuration variables from env, json, jsonc and toml files at runtime and injecting them into your environment"
  end

  defp package do
    [
      name: "enux",
      licenses: ["Apache-2.0"],
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Shayan Javani"],
      links: %{"GitHub" => @source_url}
    ]
  end

  def application do
    []
  end

  defp deps do
    [{:ex_doc, "~> 0.28", only: :dev, runtime: false}]
  end

  defp docs do
    [
      main: Enux,
      api_reference: false,
      source_url: @source_url,
      source_ref: "main",
      logo: "logo.png",
      extras: ["LICENSE", "README.md"]
    ]
  end
end
