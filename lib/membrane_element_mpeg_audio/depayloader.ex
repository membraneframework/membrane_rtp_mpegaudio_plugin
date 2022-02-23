defmodule Membrane.RTP.MPEGAudio.Depayloader do
  @moduledoc """
  Parses RTP payloads into parsable mpeg chunks based on [RFC 2038](https://tools.ietf.org/html/rfc2038#section-3.5)

  ```
   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |             MBZ               |          Frag_offset          |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ```

  MBZ: Must be zero, reserved for future use.

  Frag_offset: Byte offset into the audio frame for the data in this packet.
  """
  use Membrane.Filter
  alias Membrane.{Buffer, RTP, RemoteStream}
  alias Membrane.Caps.Audio.MPEG

  def_input_pad :input, caps: RTP, demand_mode: :auto

  def_output_pad :output,
    caps: {RemoteStream, content_format: MPEG, type: :packetized},
    demand_mode: :auto

  @impl true
  def handle_init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    caps = %RemoteStream{content_format: MPEG, type: :packetized}
    {{:ok, caps: {:output, caps}}, state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    with %Buffer{
           payload: <<0::16, _offset::16, depayloaded::binary>>
         } <- buffer do
      {{:ok, buffer: {:output, %Buffer{buffer | payload: depayloaded}}}, state}
    else
      %Buffer{} -> {{:error, :invalid_payload}, state}
    end
  end
end
