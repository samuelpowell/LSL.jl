using LSL
using Test


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



@testset "StreamOutlet" begin

info = StreamInfo(name="testname",
                  type="testtype",
                  channel_count=2,
                  nominal_srate=10,
                  channel_format=Float64,
                  source_id="testid")

outlet = StreamOutlet(info)

end

include("sample.jl")
include("chunk.jl")