# Membrane RTP MPEG Audio plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_rtp_mpegaudio_plugin.svg)](https://hex.pm/packages/membrane_rtp_mpegaudio_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_rtp_mpegaudio_plugin/)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_rtp_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_rtp_mpegaudio_plugin)

Membrane RTP MPEG Audio depayloader.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

The package can be installed by adding `membrane_rtp_mpegaudio_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_rtp_mpegaudio_plugin, "~> 0.4.0-alpha"}
  ]
end
```

Docs can be found at [HexDocs](https://hexdocs.pm/membrane_rtp_mpegaudio_plugin).

## Usage

This depayloader registers itself as a default depayloader for MPEG Audio (MPA) [RTP payload format](https://hexdocs.pm/membrane_rtp_format/Membrane.RTP.PayloadFormat.html) and thus can be automatically used by [Membrane RTP plugin](https://hexdocs.pm/membrane_rtp_plugin) whenever added to dependencies. Of course it can be manually linked in a custom pipeline too.

## Copyright and License

Copyright 2018, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

Licensed under the [Apache License, Version 2.0](LICENSE)
