#!/usr/local/bin/julia
# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# lib_send_data.jl: replicate SendDataC.c LSL application example

using LSL

function main(name, uid)

  # Create new stream info
  info = LSL.lsl_create_streaminfo(name, "EEG", 8, 500, LSL.cft_float32, uid);

  # Add meta-data fields to stream info
  desc = LSL.lsl_get_desc(info)
  LSL.lsl_append_child_value(desc, "manufacturer", "LSL")
  channels = ["C3","C4","Cz","FPz","POz","CPz","O1","O2"]
  chns = LSL.lsl_append_child(desc,"channels")
  for c in 1:8
    chn = LSL.lsl_append_child(chns,"channel")
    LSL.lsl_append_child_value(chn,"label",channels[c])
    LSL.lsl_append_child_value(chn,"unit","microvolts")
    LSL.lsl_append_child_value(chn,"type","EEG")
  end

  # Create a new outlet (chunking: default, buffering: 360 seconds)
  outlet = LSL.lsl_create_outlet(info,0,360);

  println("Waiting for consumers")
  while LSL.lsl_wait_for_consumers(outlet, 120) == 0
    sleep(0.1)
  end

  println("Now sending data...")

  # Send data until the last consumer has disconnected
  t = 0
  cursample = zeros(Float32, 8)

  while LSL.lsl_have_consumers(outlet) != 0
    cursample[1] = t;
    for c in 2:8
      cursample[c] = Float32.((rand()%1500)/500.0-1.5);
    end
    LSL.lsl_push_sample_f(outlet,cursample);
    t += 1
  end

  println("Lost the last consumer, shutting down")
  LSL.lsl_destroy_outlet(outlet);
	
end

println("lib_send_data example program: sends 8 float channels as fast as possible")
println("Usage: lib_send_data.jl [streamname] [streamuid]")
println("Using lsl $(LSL.lsl_library_version()), lsl_library info: $(unsafe_string(LSL.lsl_library_info()))")

const name = length(ARGS) > 0 ? ARGS[1] : "send_data_lib"
const uid = length(ARGS) > 1 ? ARGS[2] : "325wqer4354"

main(name, uid)


