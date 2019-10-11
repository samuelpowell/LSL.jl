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

channels = append_child(desc(info), "channels")
for label in ["C3", "C4", "Cz", "FPz", "POz", "CPz", "O1", "O2"]
  ch = append_child(channels, "channel")
  append_child_value(ch, "label", label)
  append_child_value(ch, "unit", "microvolts")
  append_child_value(ch, "type", "EEG")
end
append_child_value(desc(info), "manufacturer", "SCCN")
cap = append_child(desc(info), "cap")
append_child_value(cap, "name", "EasyCap")
append_child_value(cap, "size", "54")
append_child_value(cap, "labelscheme", "10-20")

end

# Force cleanup
GC.gc()


