defmodule Membrane.Element.RTP.MPEGAudio.DepayloaderTest do
  use ExUnit.Case
  alias Membrane.Buffer
  alias Membrane.Element.RTP.MPEGAudio.Depayloader, as: Depay

  describe "Depayloader" do
    test "returns error when incoming payload is not valid" do
      invalid_payload = %Buffer{payload: <<0::16>>}

      assert Depay.handle_process(:input, invalid_payload, nil, nil) ==
               {{:error, :invalid_payload}, nil}
    end

    test "with valid packed strips mbz and offset" do
      valid_payload = %Buffer{payload: <<0::16, 128::16, 256::8, 0::256>>}

      assert Depay.handle_process(:input, valid_payload, nil, nil) ==
               {{:ok, buffer: {:output, %Buffer{payload: <<256::8, 0::256>>}}, redemand: :output},
                nil}
    end
  end
end
