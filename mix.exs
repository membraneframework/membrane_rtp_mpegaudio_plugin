defmodule Membrane.Element.RTP.MPEGAudio.MixProject do
  use Mix.Project

  @version "0.2.0"
  @github_url "https://github.com/membraneframework/membrane-element-rtp-mpegaudio"

  def project do
    [
      app: :membrane_element_rtp_mpeguadio,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: "Membrane Multimedia Framework (RTP MPEGAudio Elements)",
      package: package(),
      name: "Membrane Element: RTP MPEGAudio",
      source_url: @github_url,
      docs: docs(),
      homepage_url: "https://membraneframework.org",
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      },
      files: ["lib", "mix.exs", "README*", "LICENSE*", ".formatter.exs", "bundlex.exs", "c_src"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:membrane_core, "~> 0.2"},
      {:membrane_caps_rtp,
       git: "git@github.com:membraneframework/membrane-caps-rtp",
       branch: "initial-caps-and-packet"},
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
