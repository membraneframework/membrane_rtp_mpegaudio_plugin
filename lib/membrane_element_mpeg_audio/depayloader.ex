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
  alias Membrane.{Buffer, RTP, Stream}
  alias Membrane.Caps.Audio.MPEG

  @default_demand 1

  def_input_pad :input, caps: RTP, demand_unit: :buffers
  def_output_pad :output, caps: {Stream, content: MPEG, type: :packet_stream}

  defmodule State do
    @moduledoc false
    defstruct [:buffer_size]

    @type t :: %State{
            buffer_size: pos_integer()
          }
  end

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    {:ok, state}
  end

  @impl true
  def handle_process(:input, buffer, context, %State{buffer_size: nil}) do
    buffer_size = byte_size(buffer.payload)
    handle_process(:input, buffer, context, %State{buffer_size: buffer_size})
  end

  def handle_process(:input, buffer, _ctx, state) do
    with %Buffer{
           payload: <<0::16, _offset::16, depayloaded::binary>>
         } <- buffer do
      {{:ok, buffer: {:output, %Buffer{buffer | payload: depayloaded}}, redemand: :output}, state}
    else
      %Buffer{} -> {{:error, :invalid_payload}, state}
    end
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  def handle_demand(:output, _size, :bytes, _context, %State{buffer_size: nil} = state) do
    {{:ok, demand: {:input, @default_demand}}, state}
  end

  def handle_demand(:output, size, :bytes, _context, %State{buffer_size: buffer_size} = state)
      when is_number(buffer_size) do
    # Demand in buffer needs to be bigger or equal to one in bytes
    demand_size =
      (size / buffer_size)
      |> Float.ceil()
      |> trunc()

    {{:ok, demand: {:input, demand_size}}, state}
  end
end
