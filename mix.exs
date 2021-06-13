defmodule Enux.MixProject do
  use Mix.Project

  def project do
    [
      app: :enux,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/massivefermion/enux",
      description: description(),
      package: package()
    ]
  end

  defp description() do
    "A module for reading variables from .env style configuration files and injecting them into your application."
  end

  defp package do
    [
      name: "enux",
      licenses: ["Apache-2.0"],
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Shayan Javani"],
      links: %{"GitHub" => "https://github.com/massivefermion/enux"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24.2", only: :dev}
    ]
  end
end
