# LSL.jl

[![Build Status](https://travis-ci.org/samuelpowell/LSL.jl.svg?branch=master)](https://travis-ci.org/samuelpowell/LSL.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/samuelpowell/LSL.jl?svg=true)](https://ci.appveyor.com/project/samuelpowell/LSL-jl)

LSL.jl is a Julia interface to the [lab streaming layer]([https://github.com/sccn/liblsl])
library.

## Installation & Platform Support

LSL is a registered package. Install using the package manager:

```julia
]add LSL
```

Official library builds are employed for Windows (x86 and x64), with Linux (x86, x64, 
ARMv7, ARMv8), MacOS and FreeBSD utilising cross-compiled libraries built using the
[BinaryProvider](https://github.com/JuliaPackaging/BinaryProvider.jl) package. Only Intel
architectures are tested with CI, so the function of the ARM builds is not gauranteed.

## Usage

LSL.jl provides an interface similar to the official 
[Python bindings](https://github.com/labstreaminglayer/liblsl-Python/), with some changes
to ensure the wrapper follows idiomatic Julia.

## Specifying a stream

A new stream is specified by building a `SteamInfo` structure:

```julia
info = StreamInfo(name = "streamname",
                  type = "streamtype",
                  channel_count = 16,
                  channel_format = Float64,
                  source_id = "streamuuid")
```

A stream information structure can be quieried using methods such as `name(info)`, 
`type(info)`, `channel_count(info)`, `nominal_srate(info)`, `channel_format(info)`, 
`source_id(info)`, `version(info)`, `created_at(info)`, `session_id(info)`, `uid(info)`,
`hostname(info)`. Get help on these and all other methods provided by the library using
the Julia help system.

## Creating a stream outlet, and pushing data

To advertise the stream on the network, and allow data to be sent, create a `StreamOutlet`
structure:

```julia
outlet = StreamOutlet(info)
```

You may push a vector of `channel_count(info)` samples of type `channel_format(info)` by 
using the `push_sample` method:

```julia
sample = rand(Float64, 16)
push_sample(outlet, sample)
```

Push a massive chunk of data consisting of many such samples with a matrix of appropriate
dimension:

```julia
chunk = rand(Float64, 16, 1024)
push_chunk(outlet, sample)
```

Check if anyone is listening to the outlet by calling `have_consumers(info)`, or block 
on a connection using `wait_for_consumers(info`). Note that the latter function is a blocking
C call, and this will prevent Julia from switching between Tasks if you choose to use this 
function in an asynchronous operation. It may be preferable to simple poll the former
function.

## Finding streams on the network

Find all streams on the network, waiting two seconds for discovery:

```julia
streams = resolve_streams(timeout = 2.0)
```

This function returns a vector of `StreamInfo` structures, each of which can be queried or
read from. Alternatively, you may wish to resolve a stream by property:

```julia
streams = resolve_byprop("source_id", "streamname", timeout = 2.0)
```

Or using a predicate:

```julia
streams = resolve_bypred("type=streamtype", timeout = 2.0)
```

## Creating a stream inlet, and reading data

To get some data, given a `StreamInfo` structure, create a `StreamInlet` structure:

```julia
inlet = StreamInlet(streams[1])
```

You can `open_stream(inlet)`, `close_stream(inlet)`, `set_postprocessing(inlet)`, and check
if `samples_available(inlet)`, etc. But probably you're more intersted in getting samples:

```julia
sample, timestamp = pull_sample(inlet, timeout = 10.0)
```

Be careful, the default timeout will wait forever (`timeout = LSL.LSL_FOREVER`). For high
performance code you may want to reuse an existing vector:

```julia
timestamp = pull_sample!(sample, inlet, timeout = 10.0)
```

To grab a chunk of data:

```julia
chunk, timestamps = pull_chunk(inlet, timeout = 10.0, max_samples = 512)
```

Since the size of the available chunk is not known until the library returns, a large
allocation (equal to a chunk size of `max_samples`) is made by this function, and resized
accordingly. This may not offer the best performance in a hot loop.


## Adding extended metadata to stream information

Streams can be annotated using structured metadata as described in the
[XDF](https://github.com/sccn/xdf) format. For example, an EEG recording may employ 
the meta-data in the associated [specification](https://github.com/sccn/xdf/wiki/EEG-Meta-Data).

```julia
info = StreamInfo(name="BioSemi",
                  type="EEG",
                  channel_count=8,
                  nominal_srate=100,
                  channel_format=Float32,
                  source_id="sub_ae852")

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
```

Full stream metadata can be rendered as XML:

```julia
XML(info)
```

## Low level library access

The full C API of liblsl is wrapped by the package, and the functions can be accessed by
their usual names, in the `lib` submodule, e.g. `LSL.lib.lsl_get_name(info)`. Julia structures
such as `StreamInfo`s, `StreamOutlet`s, and `StreamInlet`s will automatically convert to their
C handle when used as arguments to the C library. Alternatively you may get a pointer by
accesing the `.handle` property of each.
