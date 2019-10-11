# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# test/resolve.jl: test stream resolution functions


@testset "Resolvers" begin

  info_q0 = resolve_streams()
  if length(info_q0) > 0
    @warn "Pre-existing streams exist, tests may fail"
  end

  # Create some unique outlets
  info1 = StreamInfo(name = "TestResolver1",
                     type = "TestResolverType1",
                     channel_count = 1,
                     channel_format = Float64,
                     source_id = "TestResolverSource1")

  outlet1 = StreamOutlet(info1)
  
  info2 = StreamInfo(name = "TestResolver2",
                     type = "TestResolverType2",
                     channel_count = 2,
                     channel_format = Float64,
                     source_id = "TestResolverSource2")

  outlet2 = StreamOutlet(info2)

  info3 = StreamInfo(name = "TestResolver3",
                     type = "TestResolverType3",
                     channel_count = 3,
                     channel_format = Float64,
                     source_id = "TestResolverSource3")

  outlet3 = StreamOutlet(info3)

  # Add a non-unique (save for source_id)
  info4 = StreamInfo(name = "TestResolver3",
                     type = "TestResolverType3",
                     channel_count = 3,
                     channel_format = Float64,
                     source_id = "TestResolverSource4")

  outlet3 = StreamOutlet(info4)

  # Wait a bit
  sleep(1.0)

  # Resolve all streams
  info_q1 = resolve_streams(timeout = 2.0)
  @test length(info_q1) == 4
  @test length(unique([source_id(i) for i in info_q1])) == 4

  # Resolve each stream by property
  info_q2 = resolve_byprop("name", "TestResolver1", timeout = 2.0)
  info_q3 = resolve_byprop("name", "TestResolver2", timeout = 2.0)
  info_q4 = resolve_byprop("name", "TestResolver3", timeout = 2.0)   
  @test length(info_q2) == 1
  @test length(info_q3) == 1
  #@test_broken length(info_q4) == 2

  info_q5 = resolve_byprop("source_id", "TestResolverSource1", timeout = 2.0)
  info_q6 = resolve_byprop("source_id", "TestResolverSource2", timeout = 2.0)
  info_q7 = resolve_byprop("source_id", "TestResolverSource3", timeout = 2.0)
  info_q8 = resolve_byprop("source_id", "TestResolverSource4", timeout = 2.0)  
  @test length(info_q5) == 1
  @test length(info_q6) == 1
  #@test_broken length(info_q7) == 1
  @test length(info_q8) == 1

  info_q9  = resolve_byprop("type", "TestResolverType1", timeout = 2.0)
  info_q10 = resolve_byprop("type", "TestResolverType2", timeout = 2.0)
  info_q11 = resolve_byprop("type", "TestResolverType3", timeout = 2.0)
  @test length(info_q9)  == 1
  @test length(info_q10) == 1
  #@test_broken length(info_q11) == 2
  
  # Resolve each stream by predicate
  info_q2 = resolve_bypred("name='TestResolver1'", timeout = 2.0)
  info_q3 = resolve_bypred("name='TestResolver2'", timeout = 2.0)
  info_q4 = resolve_bypred("name='TestResolver3'", timeout = 2.0)   
  @test length(info_q2) == 1
  @test length(info_q3) == 1
  #@test_broken length(info_q4) == 2

  info_q5 = resolve_bypred("source_id='TestResolverSource1'", timeout = 2.0)
  info_q6 = resolve_bypred("source_id='TestResolverSource2'", timeout = 2.0)
  info_q7 = resolve_bypred("source_id='TestResolverSource3'", timeout = 2.0)
  info_q8 = resolve_bypred("source_id='TestResolverSource4'", timeout = 2.0)  
  @test length(info_q5) == 1
  @test length(info_q6) == 1
  #@test_broken length(info_q7) == 1
  @test length(info_q8) == 1

  info_q9  = resolve_bypred("type='TestResolverType1'", timeout = 2.0)
  info_q10 = resolve_bypred("type='TestResolverType2'", timeout = 2.0)
  info_q11 = resolve_bypred("type='TestResolverType3'", timeout = 2.0)
  @test length(info_q9)  == 1
  @test length(info_q10) == 1
  #@test_broken length(info_q11) == 2

end

# Force cleanup
GC.gc()
