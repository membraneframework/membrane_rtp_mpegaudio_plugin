defmodule Membrane.Element.RTP.MPEGAudio.Depayloader do
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
  use Membrane.Element.Base.Filter
  alias Membrane.Buffer
  alias Membrane.Caps.RTP

  def_output_pads output: [
                    caps: :any
                  ]

  def_input_pads input: [
                   caps: {RTP, raw_payload_type: 14, payload_type: :mpa},
                   demand_unit: :buffers
                 ]

  def_options default_demand: [
                type: :number,
                spec: pos_integer(),
                description: "Initial demand in buffers made on input pad."
              ]

  defmodule State do
    @moduledoc false
    defstruct [:buffer_size, :default_demand]

    @type t :: %State{
            buffer_size: pos_integer(),
            default_demand: pos_integer()
          }
  end

  @impl true
  def handle_init(%__MODULE__{default_demand: default_demand}) do
    {:ok, %State{default_demand: default_demand}}
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
    %State{default_demand: default_demand} = state
    {{:ok, demand: {:input, default_demand}}, state}
  end

  def handle_demand(:output, size, :bytes, _context, %State{buffer_size: buffer_size} = state)
      when is_number(buffer_size) do
    # Demand in buffer needs to be bigger or equal to one in bytes
    demand_size = Float.ceil(size / buffer_size)
    {{:ok, demand: {:input, demand_size}}, state}
  end
end
