defmodule Membrane.RTP.MPEGAudio.DepayloaderTest do
  use ExUnit.Case
  alias Membrane.Buffer
  alias Membrane.RTP.MPEGAudio.Depayloader

  describe "Depayloader when handling process" do
    setup do
      [state: %{}]
    end

    test "returns error when incoming payload is not valid", %{state: state} do
      invalid_buffer = %Buffer{payload: <<0::16>>}

      assert Depayloader.handle_process(:input, invalid_buffer, nil, state) ==
               {{:error, :invalid_payload}, state}
    end

    test "with valid packed strips mbz and offset", %{state: state} do
      valid_buffer = %Buffer{payload: <<0::16, 128::16, 256::8, 0::256>>}

      assert Depayloader.handle_process(:input, valid_buffer, nil, state) ==
               {{:ok, buffer: {:output, %Buffer{payload: <<256::8, 0::256>>}}}, state}
    end
  end
end
