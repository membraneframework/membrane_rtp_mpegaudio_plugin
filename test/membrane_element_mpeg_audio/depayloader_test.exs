defmodule Membrane.Element.RTP.MPEGAudio.DepayloaderTest do
  use ExUnit.Case
  alias Membrane.Buffer
  alias Membrane.Element.RTP.MPEGAudio.Depayloader, as: Depay
  alias Depay.State

  describe "Depayloader when handling process" do
    setup do
      [state: %State{buffer_size: 20}]
    end

    test "returns error when incoming payload is not valid", %{state: state} do
      invalid_buffer = %Buffer{payload: <<0::16>>}

      assert Depay.handle_process(:input, invalid_buffer, nil, state) ==
               {{:error, :invalid_payload}, state}
    end

    test "with valid packed strips mbz and offset", %{state: state} do
      valid_buffer = %Buffer{payload: <<0::16, 128::16, 256::8, 0::256>>}

      assert Depay.handle_process(:input, valid_buffer, nil, state) ==
               {{:ok, buffer: {:output, %Buffer{payload: <<256::8, 0::256>>}}, redemand: :output},
                state}
    end

    test "when first buffer comes it should also save it's size" do
      valid_buffer = %Buffer{payload: <<0::16, 128::16, 256::8, 0::256>>}
      expected_size = byte_size(valid_buffer.payload)

      assert Depay.handle_process(:input, valid_buffer, nil, %State{}) ==
               {{:ok, buffer: {:output, %Buffer{payload: <<256::8, 0::256>>}}, redemand: :output},
                %State{buffer_size: expected_size}}
    end
  end

  describe "Depayloader when handling demands" do
    test "when handling demand in bytes and buffer size is not set uses default value" do
      default_demand = 5
      state = %State{default_demand: default_demand}

      assert Depay.handle_demand(:output, nil, :bytes, nil, state) ==
               {{:ok, demand: {:input, default_demand}}, state}
    end

    test "when handling demand in bytes calculates demand when it is divisible by buffer size" do
      buffer_size = 1356
      multiplier = 20
      state = %State{buffer_size: buffer_size}

      assert Depay.handle_demand(:output, buffer_size * multiplier, :bytes, nil, state) ==
               {{:ok, demand: {:input, multiplier}}, state}
    end

    test "asks for an additional buffer when demand is not divisible by buffer size" do
      buffer_size = 1356
      multiplier = 20
      state = %State{buffer_size: buffer_size}

      assert Depay.handle_demand(:output, multiplier * buffer_size + 1, :bytes, nil, state) ==
               {{:ok, demand: {:input, multiplier + 1}}, state}
    end
  end
end
