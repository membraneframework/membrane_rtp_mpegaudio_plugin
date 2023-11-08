defmodule Membrane.RTP.MPEGAudio.DepayloaderPipelineTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions
  import Membrane.ChildrenSpec

  alias Membrane.RTP
  alias Membrane.RTP.MPEGAudio.Depayloader
  alias Membrane.Testing.{Pipeline, Sink, Source}

  describe "Pipeline" do
    test "does not crash when processing data" do
      base_range = 1..100
      data = Enum.map(base_range, fn elem -> <<0::32, elem::256>> end)

      {:ok, _supervisor_pid, pipeline} =
        Pipeline.start_link(
          spec: [
            child(:source, %Source{output: data, stream_format: %RTP{}})
            |> child(:depayloader, Depayloader)
            |> child(:sink, %Sink{})
          ]
        )

      Enum.each(base_range, fn elem ->
        assert_sink_buffer(pipeline, :sink, %Membrane.Buffer{payload: <<^elem::256>>})
      end)

      Membrane.Pipeline.terminate(pipeline)
    end
  end
end
