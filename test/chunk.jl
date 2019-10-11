# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# test/chunk.jl: test sending and receiving of chunks of supported datatypes

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
  testtypes = (Int8, Int16, Int32, Int64, Float32, Float64) 
else
  testtypes = (Int8, Int16, Int32, Float32, Float64) 
end

@testset "Chunk (one timestamp)" begin
  @testset "Datatype $T" for T in testtypes

    # Create a stream outlet
    count = 32
    chunks = 512

    info = StreamInfo(name = "TestName",
                      type = "Test$(string(T))",
                      channel_count = count,
                      channel_format = T,
                      source_id = "ChunkOneTest$(string(T))ID")

    outlet = StreamOutlet(info)    

    # Resolve the stream with modest timeout, and create inlet
    streams = resolve_byprop("source_id", "ChunkOneTest$(string(T))ID", timeout = 5.0)
    inlet = StreamInlet(streams[1])
    open_stream(inlet)
    #sleep(0.5)

    # Make some data, and send it once the inlet has opened
    data_in = rand(T, count, chunks)
    push_chunk(outlet, data_in)
    #sleep(0.5)

    # Pull the sample
    timestamps, data_out = pull_chunk(inlet, max_samples = chunks, timeout = 15.0)
    @test all(data_out .== data_in[:, 1:size(data_out,2)])
    @test size(data_out,2) == chunks

    # Close the stream
    close_stream(inlet)

  end

  # Force cleanup
  GC.gc()

end

@testset "Chunk (multiple timestamp)" begin
  @testset "Datatype $T" for T in testtypes

    # Create a stream outlet
    count = 32
    chunks = 512

    info = StreamInfo(name = "TestName",
                      type = "Test$(string(T))",
                      channel_count = count,
                      channel_format = T,
                      source_id = "ChunkMultiTest$(string(T))ID")

    outlet = StreamOutlet(info)    

    # Resolve the stream with modest timeout, and create inlet
    streams = resolve_byprop("source_id", "ChunkMultiTest$(string(T))ID", timeout = 5.0)
    inlet = StreamInlet(streams[1])
    open_stream(inlet)
    #sleep(0.5)

    # Make some data, and send it once the inlet has opened
    data_in = rand(T, count, chunks)
    timestamps_in = rand(Float64, chunks)
    push_chunk(outlet, data_in, timestamps_in)
    #sleep(0.5)

    # Pull the sample
    timestamps, data_out = pull_chunk(inlet, max_samples = chunks, timeout = 15.0)
    @test all(data_out .== data_in[:, 1:size(data_out,2)])
    @test all(timestamps .== timestamps_in[1:size(data_out,2)])
    @test size(data_out,2) == chunks

    # Close the stream
    close_stream(inlet)

  end

  # Force cleanup
  GC.gc()

end