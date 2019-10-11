# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# StreamInfo.jl: type and method definitions for steam information object

import Base.unsafe_convert
import Base.show

export StreamInfo
export name, type, channel_count, nominal_srate, channel_format, source_id
export version, created_at, session_id, uid, hostname
export desc, XML

"""
    StreamInfo
    
The StreamInfo type stores the declaration of a data stream.

Represents the following information:
 a) stream data format (#channels, channel format)
 b) core information (stream name, content type, sampling rate)
 c) optional meta-data about the stream content (channel labels, 
    measurement units, etc.)

Whenever a program wants to provide a new stream on the lab network it will typically first
create a StreamInfo to describe its properties and then construct a StreamOutlet with it to
create the stream on the network. Recipients who discover the outlet can query the
StreamInfo; it is also written to disk when recording the stream (playing a similar role as
a file header).
"""
mutable struct StreamInfo{T}
  handle::lib.lsl_streaminfo
  format::Type{T}

  function StreamInfo(handle, format::Type{T}) where T
    info = new{T}(handle, format)
    finalizer(_destroy, info)
  end
  
end

# Define conversion to pointer
unsafe_convert(::Type{lib.lsl_streaminfo}, info::StreamInfo) = info.handle

# Define constructor
"""
    StreamInfo(name = "untitled";
               type = "", 
               channel_count = 1,
               nominal_srate = LSL_IRREGULAR_RATE,
               channel_format = Float32,
               source_id = "")

Construct a new stream information object.

Core stream information is specified here. Any remaining meta-data can be added later.

# Keyword arguments
- `name::String`: Name of the stream. Describes the device (or product series)    
                  that this stream makes available (for use by programs, experimenters or
                  data analysts). Cannot be empty.                
- `type::String`: Content type of the stream. Please see https://github.com/sccn/xdf/wiki/Meta-Data
                  (or web search for: XDF meta-data) for pre-defined content-type names, but
                  you can also make up your own. The content type is the preferred way to
                  find streams (as opposed to searching by name).
- `channel_count::Integer`:   Number of channels per sample. This stays constant for the
                              lifetime of the stream.
- `nominal_srate::Number`:    The sampling rate (in Hz) as advertised by the datasource, if
                              regular (otherwise set to LSL_IRREGULAR_RATE).
- `channel_format::DataType`: Format/type of each channel.If your channels have different
                              formats, consider supplying multiple streams or use the
                              largest type that can hold them all (such as Float64).
 - `source_id::String`:       Unique identifier of the source or device, if available
                              (such as the serial number). Allows recipients to recover from
                              failure even after the serving app or device crashes. May in
                              some cases also be constructed from device settings.
"""
function StreamInfo(; name::String = "untitled",
                      type::String = "", 
                      channel_count::Integer = 1,
                      nominal_srate::Number = IRREGULAR_RATE,
                      channel_format::DataType = Float32,
                      source_id::String = "")

  # Get LSL format, create and test handle
  format = _lsl_channel_format(channel_format)
  handle = lib.lsl_create_streaminfo(name, type, channel_count, nominal_srate, format, source_id)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during StreamInfo creation")
  end

  return StreamInfo(handle, channel_format)
end

# Destroy a StreamInfo handle
function _destroy(info::StreamInfo)
  if info.handle != C_NULL
    lib.lsl_destroy_streaminfo(info)
  end
  return nothing
end

# function Base.show(io::IO, info::StreamInfo)
#   print(io, "Stream ", source_id(info), "\tname: ", name(info), "\ttype: ", type(info))
# end





#
# Core information retrieval (assigned at construction)
#

"""
    name(info::StreamInfo)

Return name of the stream `info`.

This is a human-readable name. For streams offered by device modules, it refers to the type
of device or product series that is generating the data of the stream. If the source is an
application, the name may be a more generic or specific identifier. Multiple streams with
the same name can coexist, though potentially at the cost of ambiguity (for the recording
app or experimenter).
"""
name(info::StreamInfo) = unsafe_string(lib.lsl_get_name(info))

"""
    type(info::StreamInfo)

Return the content type of the stream `info`.

The content type is a short string such as "EEG", "Gaze" which describes the content carried
by the channel (if known). If a stream contains mixed content this value need not be
assigned but may instead be stored in the description of channel types. To be useful to
applications and automated processing systems using the recommended content types is
preferred. Content types usually follow those pre-defined in https://github.com/sccn/xdf/wiki/Meta-Data
(or web search for: XDF meta-data).
"""
type(info::StreamInfo) = unsafe_string(lib.lsl_get_type(info))

"""
    channel_count(info::StreamInfo)

Return mumber of channels of the stream `info`.

A stream has at least one channel; the channel count stays constant for all samples.
"""
channel_count(info::StreamInfo) = lib.lsl_get_channel_count(info)

"""
    nominal_srate(info::StreamInfo)

Return sampling rate of the stream `info`, according to the source (in Hz).

If a stream is irregularly sampled, this should be set to IRREGULAR_RATE.

Note that no data will be lost even if this sampling rate is incorrect or if a device has
temporary hiccups, since all samples will be recorded anyway (except for those dropped by
the device itself). However, when the recording is imported into an application, a good
importer may correct such errors more accurately if the advertised sampling rate was close
to the specs of the device.
"""
nominal_srate(info::StreamInfo) = lib.lsl_get_nominal_srate(info)

""" 
    channel_format(info::StreamInfo)

Return (Julia) channel format of the stream `info`.

All channels in a stream have the same format. However, a device might offer multiple
time-synched streams each with its own format.

Note that the format is returned from the parametric type of the StreamInfo object, it is
not queried from the library.
"""
channel_format(info::StreamInfo{T}) where T = T

"""
    source_id(info::StreamInfo)

Return unique identifier of the stream's source, if available.

The unique source (or device) identifier is an optional piece of information that, if
available, allows that endpoints (such as the recording program) can re-acquire a stream
automatically once it is back online.
"""
source_id(info::StreamInfo) = unsafe_string(lib.lsl_get_source_id(info))



#
# Hosting information (assigned when bound to an outlet/inlet)
#

"""
    version(info::SteramInfo)

Return protocol version used to deliver the stream.
"""
function version(info::StreamInfo) 
  major, minor = divrem(lib.lsl_get_version(info), 100)
  return VersionNumber(major, minor)
end

"""
    created_at(info::StreamInfo)

Return creation time stamp of the stream.

This is the time stamp when the stream was first created (as determined via local_clock()
on the providing machine).
"""
created_at(info::StreamInfo) = lib.lsl_get_created_at(info)

"""
    uid(info::StreamInfo)

Return unique ID of the stream outlet (once assigned).

This is a unique identifier of the stream outlet, and is guaranteed to be different across
multiple instantiations of the same outlet (e.g., after a re-start). 
"""
uid(info::StreamInfo) = unsafe_string(lib.lsl_get_uid(info))

"""
    session_id(info::StreamInfo)

Return session ID for the given stream.

The session id is an optional human-assigned identifier of the recording session. While it
is rarely used, it can be used to prevent concurrent recording activitites in the same
sub-network (e.g., in multiple experiment areas) from seeing each other's streams (assigned
via a configuration file by the experimenter, see Network Connectivity on the LSL wiki).
"""
session_id(info::StreamInfo) = unsafe_string(lib.lsl_get_session_id(info))

"""
    hostname(info::StreamInfo)

Return hostname of the providing machine (once bound to an outlet). Modification is not
permitted.
"""
hostname(info::StreamInfo) = unsafe_string(lib.lsl_get_hostname(info))

 
#
# Data description (can be modified)
#

"""
    desc(info::StreamInfo)

Get extended description of the stream as an XMLElement.

It is highly recommended that at least the channel labels are described here. See code
examples on the LSL wiki. Other information, such as amplifier settings, measurement units
if deviating from defaults, setup information, subject information, etc., can be specified
here, as well. Meta-data recommendations follow the XDF file format project
(github.com/sccn/xdf/wiki/Meta-Data or web search for: XDF meta-data).

Important: if you use a stream content type for which meta-data recommendations exist, please 
try to lay out your meta-data in agreement with these recommendations for compatibility with
other applications.
"""
desc(info::StreamInfo) = LSLXMLElement(lib.lsl_get_desc(info))

"""
    XML(info::StreamInfo)

Return XML document (from LightXML) containing the entire StreamInfo.

This yields an XML document whose top-level element is `<info>`. The info element contains
one element for each field of the StreamInfo instance, including:

- the core elements `<name>`, `<type>`, `<channel_count`, `<nominal_srate>`, 
  `<channel_format>`, `<source_id>`
- the misc elements `<version>`, `<created_at>`, `<uid>`, `<session_id>`, `<v4address>`,
  `<v4data_port>`, `<v4service_port>`, `<v6address>`, `<v6data_port>`, `<v6service_port>`
- the extended description element `<desc>` with user-defined sub-elements.
"""
function XML(info::StreamInfo)
    xml_string_ptr = lib.lsl_get_xml(info)
    if xml_string_ptr == C_NULL
      error("liblsl returned NULL pointer when requesting XML stream information")
    end
    xmldoc = LightXML.parse_string(unsafe_string(xml_string_ptr))
    lib.lsl_destroy_string(xml_string_ptr)
    return xmldoc
end


# /// Number of bytes occupied by a channel (0 for string-typed channels).
# extern LIBLSL_C_API int32_t lsl_get_channel_bytes(lsl_streaminfo info);

# /// Number of bytes occupied by a sample (0 for string-typed channels).
# extern LIBLSL_C_API int32_t lsl_get_sample_bytes(lsl_streaminfo info);

# /**
#  * Tries to match the stream info XML element @p info against an
#  * <a href="https://en.wikipedia.org/wiki/XPath#Syntax_and_semantics_(XPath_1.0)">XPath</a> query.
#  *
#  * Example query strings:
#  * @code
#  * channel_count>5 and type='EEG'
#  * type='TestStream' or contains(name,'Brain')
#  * name='ExampleStream'
#  * @endcode
#  */
# extern LIBLSL_C_API int lsl_stream_info_matches_query(lsl_streaminfo info, const char* query);

# /// Create a streaminfo object from an XML representation
# extern LIBLSL_C_API lsl_streaminfo lsl_streaminfo_from_xml(const char *xml);

