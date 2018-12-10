defmodule Membrane.Element.RTP.MPEGAudio do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Membrane.Element.RTP.MPEGAudio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
