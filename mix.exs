defmodule Enux.MixProject do
  use Mix.Project

  @source_url "https://github.com/massivefermion/enux"

  def project do
    [
      app: :enux,
      version: "0.8.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      description: description(),
      package: package(),
      aliases: aliases(),
      docs: [
        main: "Enux",
        api_reference: true,
        source_url: @source_url,
        source_ref: "main",
        logo: "logo.png"
      ]
    ]
  end

  defp description() do
    "dynamic configuration management by importing your environment variables from env and json style configuration files at runtime.

    you don't need to compile your code again after changing a variable."
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
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24.2", only: :docs}
    ]
  end

  defp aliases do
    [
      gen_docs: ["cmd MIX_ENV=docs mix docs"],
      publish: ["cmd MIX_ENV=docs mix hex.publish --replace"]
    ]
  end
end
