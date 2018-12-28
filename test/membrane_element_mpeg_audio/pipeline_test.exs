defmodule Membrane.Element.RTP.MPEGAudio.DepayloaderPipelineTest do
  use ExUnit.Case

  alias Membrane.Element.RTP.MPEGAudio.Depayloader
  alias Membrane.Testing.{DataSource, Pipeline, Sink}

  describe "Pipeline" do
    test "does not crash when processing data" do
      base_range = 1..100
      data = Enum.map(base_range, fn elem -> <<0::32, elem::256>> end)

      {:ok, pipeline} =
        Pipeline.start_link(%Pipeline.Options{
          elements: [
            source: %DataSource{data: data},
            depayloader: Depayloader,
            sink: %Sink{target: self()}
          ]
        })

      Membrane.Pipeline.play(pipeline)

      Enum.each(base_range, fn elem ->
        assert_receive %Membrane.Buffer{payload: <<^elem::256>>}
      end)
    end
  end
end
