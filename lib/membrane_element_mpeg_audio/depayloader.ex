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
  alias Membrane.{Buffer, RemoteStream, RTP}
  alias Membrane.Caps.Audio.MPEG

  def_input_pad :input, accepted_format: %RTP{payload_format: format} when format in [nil, MPEG]

  def_output_pad :output,
    accepted_format: %RemoteStream{content_format: MPEG, type: :packetized}

  @impl true
  def handle_init(_ctx, _opts) do
    {[], %{}}
  end

  @impl true
  def handle_stream_format(:input, _stream_format, _ctx, state) do
    stream_format = %RemoteStream{content_format: MPEG, type: :packetized}
    {[stream_format: {:output, stream_format}], state}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    with %Buffer{payload: <<0::16, _offset::16, depayloaded::binary>>} <- buffer do
      {[buffer: {:output, %Buffer{buffer | payload: depayloaded}}], state}
    else
      %Buffer{} -> raise "Error: invalid payload: #{inspect(buffer.payload)}"
    end
  end
end
