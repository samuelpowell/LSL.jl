# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# test/sample.jl: test sending and receiving of samples supported datatypes

@testset "Samples" begin
  @testset "Datatype $T" for T in (Int8, Int16, Int32, Int64, Float32, Float64) 

    # Create a stream outlet
    count = 8

    info = StreamInfo(name = "TestName",
                      type = "Test$(string(T))",
                      channel_count = count,
                      channel_format = T,
                      source_id = "SampleTest$(string(T))ID")

    outlet = StreamOutlet(info)    

    # Resolve the stream with modest timeout, and create inlet
    streams = resolve_byprop("source_id", "SampleTest$(string(T))ID", timeout = 5.0)
    inlet = StreamInlet(streams[1])
    open_stream(inlet)

    # Make some data, and send it once the inlet has opened
    data_in = rand(T, count)
    push_sample(outlet, data_in)

    # Pull the sample
    timestamp, data_out = pull_sample(inlet, timeout = 10.0)
    @test all(data_out .== data_in)

    # Close the stream
    close_stream(inlet)

  end
end

