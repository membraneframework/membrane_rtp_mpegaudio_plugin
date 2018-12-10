defmodule Membrane.Element.RTP.MPEGAudio.Depayloader do
  @moduledoc """
  Parses RTP payloads into parsable mpeg chunks based on RFC 2038
  """
  use Membrane.Element.Base.Filter
  alias Membrane.Buffer

  def_output_pads output: [
                    caps: :any
                  ]

  def_input_pads input: [
                   caps: :any,
                   demand_unit: :buffers
                 ]

  @doc """
  0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |             MBZ               |          Frag_offset          |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

  MBZ: Must be zero, reserved for future use.

  Frag_offset: Byte offset into the audio frame for the data
  in this packet.
  """
  @impl true
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
  def handle_demand(:output, size, _, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end
end
