defmodule Membrane.RTP.MPEGAudio.Plugin.App do
  @moduledoc false
  use Application
  alias Membrane.RTP.{MPEGAudio, PayloadFormat}

  def start(_type, _args) do
    PayloadFormat.register(%PayloadFormat{
      encoding_name: :MPA,
      depayloader: MPEGAudio.Depayloader
    })

    Supervisor.start_link([], strategy: :one_for_one, name: __MODULE__)
  end
end
