# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# test/streaminfo.jl: test stream information functions

@testset "StreamInfo" begin

info = StreamInfo(name="testname",
                  type="testtype",
                  channel_count=2,
                  nominal_srate=10,
                  channel_format=Float64,
                  source_id="testid")

@test name(info) == "testname"
@test type(info) == "testtype"
@test channel_count(info) == 2
@test nominal_srate(info) == 10
@test channel_format(info) == Float64
@test source_id(info) == "testid"

@test version(info) == protocol_version()

end
