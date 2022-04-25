defmodule Membrane.RTP.MPEGAudio.MixProject do
  use Mix.Project

  @version "0.9.0"
  @github_url "https://github.com/membraneframework/membrane_rtp_mpegaudio_plugin"

  def project do
    [
      app: :membrane_rtp_mpegaudio_plugin,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),

      # Hex
      description: "Membrane RTP MPEG Audio depayloader",
      package: package(),

      # docs
      name: "Membrane RTP MPEG Audio plugin",
      source_url: @github_url,
      docs: docs(),
      homepage_url: "https://membraneframework.org"
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {Membrane.RTP.MPEGAudio.Plugin.App, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp docs do
    [
      main: "readme",
      extras: ["README.md", LICENSE: [title: "License"]],
      formatters: ["html"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp deps do
    [
      {:membrane_core, "~> 0.10.0"},
      {:membrane_rtp_format, "~> 0.3.0"},
      {:membrane_caps_audio_mpeg, "~> 0.2.0"},

      # dev
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: :dev, runtime: false}
    ]
  end
end
