defmodule Enux.MixProject do
  use Mix.Project

  @source_url "https://github.com/massivefermion/enux"

  def project do
    [
      app: :enux,
      version: "1.0.2",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp description() do
    "Helper module to load, validate and document your app's configuration from env, json and jsonc files at runtime."
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
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
