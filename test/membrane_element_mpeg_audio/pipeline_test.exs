defmodule Membrane.RTP.MPEGAudio.DepayloaderPipelineTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  alias Membrane.RTP.MPEGAudio.Depayloader
  alias Membrane.Testing.{Source, Pipeline, Sink}

  describe "Pipeline" do
    test "does not crash when processing data" do
      base_range = 1..100
      data = Enum.map(base_range, fn elem -> <<0::32, elem::256>> end)

      {:ok, pipeline} =
        Pipeline.start_link(%Pipeline.Options{
          elements: [
            source: %Source{output: data},
            depayloader: Depayloader,
            sink: %Sink{}
          ]
        })

      Membrane.Pipeline.play(pipeline)

      Enum.each(base_range, fn elem ->
        assert_sink_buffer(pipeline, :sink, %Membrane.Buffer{payload: <<^elem::256>>})
      end)
    end
  end
end
