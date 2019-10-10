# Julia wrapper for header: lsl_constants.h
# Automatically generated using Clang.jl

# Julia wrapper for header: lsl_c.h
# Automatically generated using Clang.jl


function lsl_protocol_version()
    ccall((:lsl_protocol_version, liblsl), Int32, ())
end

function lsl_library_version()
    ccall((:lsl_library_version, liblsl), Int32, ())
end

function lsl_library_info()
    ccall((:lsl_library_info, liblsl), Cstring, ())
end

function lsl_local_clock()
    ccall((:lsl_local_clock, liblsl), Cdouble, ())
end

function lsl_resolve_all(buffer, buffer_elements, wait_time)
    ccall((:lsl_resolve_all, liblsl), Int32, (Ptr{lsl_streaminfo}, UInt32, Cdouble), buffer, buffer_elements, wait_time)
end

function lsl_resolve_byprop(buffer, buffer_elements, prop, value, minimum, timeout)
    ccall((:lsl_resolve_byprop, liblsl), Int32, (Ptr{lsl_streaminfo}, UInt32, Cstring, Cstring, Int32, Cdouble), buffer, buffer_elements, prop, value, minimum, timeout)
end

function lsl_resolve_bypred(buffer, buffer_elements, pred, minimum, timeout)
    ccall((:lsl_resolve_bypred, liblsl), Int32, (Ptr{lsl_streaminfo}, UInt32, Cstring, Int32, Cdouble), buffer, buffer_elements, pred, minimum, timeout)
end

function lsl_destroy_string(s)
    ccall((:lsl_destroy_string, liblsl), Cvoid, (Cstring,), s)
end

function lsl_create_streaminfo(name, type, channel_count, nominal_srate, channel_format, source_id)
    ccall((:lsl_create_streaminfo, liblsl), lsl_streaminfo, (Cstring, Cstring, Int32, Cdouble, lsl_channel_format_t, Cstring), name, type, channel_count, nominal_srate, channel_format, source_id)
end

function lsl_destroy_streaminfo(info)
    ccall((:lsl_destroy_streaminfo, liblsl), Cvoid, (lsl_streaminfo,), info)
end

function lsl_copy_streaminfo(info)
    ccall((:lsl_copy_streaminfo, liblsl), lsl_streaminfo, (lsl_streaminfo,), info)
end

function lsl_get_name(info)
    ccall((:lsl_get_name, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_type(info)
    ccall((:lsl_get_type, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_channel_count(info)
    ccall((:lsl_get_channel_count, liblsl), Int32, (lsl_streaminfo,), info)
end

function lsl_get_nominal_srate(info)
    ccall((:lsl_get_nominal_srate, liblsl), Cdouble, (lsl_streaminfo,), info)
end

function lsl_get_channel_format(info)
    ccall((:lsl_get_channel_format, liblsl), lsl_channel_format_t, (lsl_streaminfo,), info)
end

function lsl_get_source_id(info)
    ccall((:lsl_get_source_id, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_version(info)
    ccall((:lsl_get_version, liblsl), Int32, (lsl_streaminfo,), info)
end

function lsl_get_created_at(info)
    ccall((:lsl_get_created_at, liblsl), Cdouble, (lsl_streaminfo,), info)
end

function lsl_get_uid(info)
    ccall((:lsl_get_uid, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_session_id(info)
    ccall((:lsl_get_session_id, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_hostname(info)
    ccall((:lsl_get_hostname, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_desc(info)
    ccall((:lsl_get_desc, liblsl), lsl_xml_ptr, (lsl_streaminfo,), info)
end

function lsl_get_xml(info)
    ccall((:lsl_get_xml, liblsl), Cstring, (lsl_streaminfo,), info)
end

function lsl_get_channel_bytes(info)
    ccall((:lsl_get_channel_bytes, liblsl), Int32, (lsl_streaminfo,), info)
end

function lsl_get_sample_bytes(info)
    ccall((:lsl_get_sample_bytes, liblsl), Int32, (lsl_streaminfo,), info)
end

function lsl_stream_info_matches_query(info, query)
    ccall((:lsl_stream_info_matches_query, liblsl), Int32, (lsl_streaminfo, Cstring), info, query)
end

function lsl_streaminfo_from_xml(xml)
    ccall((:lsl_streaminfo_from_xml, liblsl), lsl_streaminfo, (Cstring,), xml)
end

function lsl_create_outlet(info, chunk_size, max_buffered)
    ccall((:lsl_create_outlet, liblsl), lsl_outlet, (lsl_streaminfo, Int32, Int32), info, chunk_size, max_buffered)
end

function lsl_destroy_outlet(out)
    ccall((:lsl_destroy_outlet, liblsl), Cvoid, (lsl_outlet,), out)
end

function lsl_push_sample_f(out, data)
    ccall((:lsl_push_sample_f, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}), out, data)
end

function lsl_push_sample_d(out, data)
    ccall((:lsl_push_sample_d, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}), out, data)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_sample_l(out, data)
        ccall((:lsl_push_sample_l, liblsl), Int32, (lsl_outlet, Ptr{Clong}), out, data)
    end
end

function lsl_push_sample_i(out, data)
    ccall((:lsl_push_sample_i, liblsl), Int32, (lsl_outlet, Ptr{Int32}), out, data)
end

function lsl_push_sample_s(out, data)
    ccall((:lsl_push_sample_s, liblsl), Int32, (lsl_outlet, Ptr{Int16}), out, data)
end

function lsl_push_sample_c(out, data)
    ccall((:lsl_push_sample_c, liblsl), Int32, (lsl_outlet, Ptr{Cchar}), out, data)
end

function lsl_push_sample_v(out, data)
    ccall((:lsl_push_sample_v, liblsl), Int32, (lsl_outlet, Ptr{Cvoid}), out, data)
end

function lsl_push_sample_ft(out, data, timestamp)
    ccall((:lsl_push_sample_ft, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Cdouble), out, data, timestamp)
end

function lsl_push_sample_dt(out, data, timestamp)
    ccall((:lsl_push_sample_dt, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Cdouble), out, data, timestamp)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_sample_lt(out, data, timestamp)
        ccall((:lsl_push_sample_lt, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Cdouble), out, data, timestamp)
    end
end

function lsl_push_sample_it(out, data, timestamp)
    ccall((:lsl_push_sample_it, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Cdouble), out, data, timestamp)
end

function lsl_push_sample_st(out, data, timestamp)
    ccall((:lsl_push_sample_st, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Cdouble), out, data, timestamp)
end

function lsl_push_sample_ct(out, data, timestamp)
    ccall((:lsl_push_sample_ct, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Cdouble), out, data, timestamp)
end

function lsl_push_sample_vt(out, data, timestamp)
    ccall((:lsl_push_sample_vt, liblsl), Int32, (lsl_outlet, Ptr{Cvoid}, Cdouble), out, data, timestamp)
end

function lsl_push_sample_ftp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_ftp, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

function lsl_push_sample_dtp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_dtp, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_sample_ltp(out, data, timestamp, pushthrough)
        ccall((:lsl_push_sample_ltp, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Cdouble, Int32), out, data, timestamp, pushthrough)
    end
end

function lsl_push_sample_itp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_itp, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

function lsl_push_sample_stp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_stp, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

function lsl_push_sample_ctp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_ctp, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

function lsl_push_sample_strtp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_strtp, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

function lsl_push_sample_vtp(out, data, timestamp, pushthrough)
    ccall((:lsl_push_sample_vtp, liblsl), Int32, (lsl_outlet, Ptr{Cvoid}, Cdouble, Int32), out, data, timestamp, pushthrough)
end

function lsl_push_sample_buf(out, data, lengths)
    ccall((:lsl_push_sample_buf, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}), out, data, lengths)
end

function lsl_push_sample_buft(out, data, lengths, timestamp)
    ccall((:lsl_push_sample_buft, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Cdouble), out, data, lengths, timestamp)
end

function lsl_push_sample_buftp(out, data, lengths, timestamp, pushthrough)
    ccall((:lsl_push_sample_buftp, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Cdouble, Int32), out, data, lengths, timestamp, pushthrough)
end

function lsl_push_chunk_f(out, data, data_elements)
    ccall((:lsl_push_chunk_f, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Culong), out, data, data_elements)
end

function lsl_push_chunk_d(out, data, data_elements)
    ccall((:lsl_push_chunk_d, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Culong), out, data, data_elements)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_chunk_l(out, data, data_elements)
        ccall((:lsl_push_chunk_l, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Culong), out, data, data_elements)
    end
end

function lsl_push_chunk_i(out, data, data_elements)
    ccall((:lsl_push_chunk_i, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Culong), out, data, data_elements)
end

function lsl_push_chunk_s(out, data, data_elements)
    ccall((:lsl_push_chunk_s, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Culong), out, data, data_elements)
end

function lsl_push_chunk_c(out, data, data_elements)
    ccall((:lsl_push_chunk_c, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Culong), out, data, data_elements)
end

function lsl_push_chunk_ft(out, data, data_elements, timestamp)
    ccall((:lsl_push_chunk_ft, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Culong, Cdouble), out, data, data_elements, timestamp)
end

function lsl_push_chunk_dt(out, data, data_elements, timestamp)
    ccall((:lsl_push_chunk_dt, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Culong, Cdouble), out, data, data_elements, timestamp)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_chunk_lt(out, data, data_elements, timestamp)
        ccall((:lsl_push_chunk_lt, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Culong, Cdouble), out, data, data_elements, timestamp)
    end
end

function lsl_push_chunk_it(out, data, data_elements, timestamp)
    ccall((:lsl_push_chunk_it, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Culong, Cdouble), out, data, data_elements, timestamp)
end

function lsl_push_chunk_st(out, data, data_elements, timestamp)
    ccall((:lsl_push_chunk_st, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Culong, Cdouble), out, data, data_elements, timestamp)
end

function lsl_push_chunk_ct(out, data, data_elements, timestamp)
    ccall((:lsl_push_chunk_ct, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Culong, Cdouble), out, data, data_elements, timestamp)
end

function lsl_push_chunk_strt(out, data, data_elements, timestamp)
    ccall((:lsl_push_chunk_strt, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Culong, Cdouble), out, data, data_elements, timestamp)
end

function lsl_push_chunk_ftp(out, data, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_ftp, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
end

function lsl_push_chunk_dtp(out, data, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_dtp, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_chunk_ltp(out, data, data_elements, timestamp, pushthrough)
        ccall((:lsl_push_chunk_ltp, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
    end
end

function lsl_push_chunk_itp(out, data, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_itp, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
end

function lsl_push_chunk_stp(out, data, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_stp, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
end

function lsl_push_chunk_ctp(out, data, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_ctp, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
end

function lsl_push_chunk_strtp(out, data, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_strtp, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Culong, Cdouble, Int32), out, data, data_elements, timestamp, pushthrough)
end

function lsl_push_chunk_ftn(out, data, data_elements, timestamps)
    ccall((:lsl_push_chunk_ftn, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
end

function lsl_push_chunk_dtn(out, data, data_elements, timestamps)
    ccall((:lsl_push_chunk_dtn, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_chunk_ltn(out, data, data_elements, timestamps)
        ccall((:lsl_push_chunk_ltn, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
    end
end

function lsl_push_chunk_itn(out, data, data_elements, timestamps)
    ccall((:lsl_push_chunk_itn, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
end

function lsl_push_chunk_stn(out, data, data_elements, timestamps)
    ccall((:lsl_push_chunk_stn, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
end

function lsl_push_chunk_ctn(out, data, data_elements, timestamps)
    ccall((:lsl_push_chunk_ctn, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
end

function lsl_push_chunk_strtn(out, data, data_elements, timestamps)
    ccall((:lsl_push_chunk_strtn, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Culong, Ptr{Cdouble}), out, data, data_elements, timestamps)
end

function lsl_push_chunk_ftnp(out, data, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_ftnp, liblsl), Int32, (lsl_outlet, Ptr{Cfloat}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
end

function lsl_push_chunk_dtnp(out, data, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_dtnp, liblsl), Int32, (lsl_outlet, Ptr{Cdouble}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_push_chunk_ltnp(out, data, data_elements, timestamps, pushthrough)
        ccall((:lsl_push_chunk_ltnp, liblsl), Int32, (lsl_outlet, Ptr{Clong}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
    end
end

function lsl_push_chunk_itnp(out, data, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_itnp, liblsl), Int32, (lsl_outlet, Ptr{Int32}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
end

function lsl_push_chunk_stnp(out, data, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_stnp, liblsl), Int32, (lsl_outlet, Ptr{Int16}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
end

function lsl_push_chunk_ctnp(out, data, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_ctnp, liblsl), Int32, (lsl_outlet, Ptr{Cchar}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
end

function lsl_push_chunk_strtnp(out, data, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_strtnp, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Culong, Ptr{Cdouble}, Int32), out, data, data_elements, timestamps, pushthrough)
end

function lsl_push_chunk_buf(out, data, lengths, data_elements)
    ccall((:lsl_push_chunk_buf, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Culong), out, data, lengths, data_elements)
end

function lsl_push_chunk_buft(out, data, lengths, data_elements, timestamp)
    ccall((:lsl_push_chunk_buft, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Culong, Cdouble), out, data, lengths, data_elements, timestamp)
end

function lsl_push_chunk_buftp(out, data, lengths, data_elements, timestamp, pushthrough)
    ccall((:lsl_push_chunk_buftp, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Culong, Cdouble, Int32), out, data, lengths, data_elements, timestamp, pushthrough)
end

function lsl_push_chunk_buftn(out, data, lengths, data_elements, timestamps)
    ccall((:lsl_push_chunk_buftn, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Culong, Ptr{Cdouble}), out, data, lengths, data_elements, timestamps)
end

function lsl_push_chunk_buftnp(out, data, lengths, data_elements, timestamps, pushthrough)
    ccall((:lsl_push_chunk_buftnp, liblsl), Int32, (lsl_outlet, Ptr{Cstring}, Ptr{UInt32}, Culong, Ptr{Cdouble}, Int32), out, data, lengths, data_elements, timestamps, pushthrough)
end

function lsl_have_consumers(out)
    ccall((:lsl_have_consumers, liblsl), Int32, (lsl_outlet,), out)
end

function lsl_wait_for_consumers(out, timeout)
    ccall((:lsl_wait_for_consumers, liblsl), Int32, (lsl_outlet, Cdouble), out, timeout)
end

function lsl_get_info(out)
    ccall((:lsl_get_info, liblsl), lsl_streaminfo, (lsl_outlet,), out)
end

function lsl_create_inlet(info, max_buflen, max_chunklen, recover)
    ccall((:lsl_create_inlet, liblsl), lsl_inlet, (lsl_streaminfo, Int32, Int32, Int32), info, max_buflen, max_chunklen, recover)
end

function lsl_destroy_inlet(in)
    ccall((:lsl_destroy_inlet, liblsl), Cvoid, (lsl_inlet,), in)
end

function lsl_get_fullinfo(in, timeout, ec)
    ccall((:lsl_get_fullinfo, liblsl), lsl_streaminfo, (lsl_inlet, Cdouble, Ptr{Int32}), in, timeout, ec)
end

function lsl_open_stream(in, timeout, ec)
    ccall((:lsl_open_stream, liblsl), Cvoid, (lsl_inlet, Cdouble, Ptr{Int32}), in, timeout, ec)
end

function lsl_close_stream(in)
    ccall((:lsl_close_stream, liblsl), Cvoid, (lsl_inlet,), in)
end

function lsl_time_correction(in, timeout, ec)
    ccall((:lsl_time_correction, liblsl), Cdouble, (lsl_inlet, Cdouble, Ptr{Int32}), in, timeout, ec)
end

function lsl_time_correction_ex(in, remote_time, uncertainty, timeout, ec)
    ccall((:lsl_time_correction_ex, liblsl), Cdouble, (lsl_inlet, Ptr{Cdouble}, Ptr{Cdouble}, Cdouble, Ptr{Int32}), in, remote_time, uncertainty, timeout, ec)
end

function lsl_set_postprocessing(in, flags)
    ccall((:lsl_set_postprocessing, liblsl), Int32, (lsl_inlet, UInt32), in, flags)
end

function lsl_pull_sample_f(in, buffer, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_f, liblsl), Cdouble, (lsl_inlet, Ptr{Cfloat}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
end

function lsl_pull_sample_d(in, buffer, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_d, liblsl), Cdouble, (lsl_inlet, Ptr{Cdouble}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_pull_sample_l(in, buffer, buffer_elements, timeout, ec)
        ccall((:lsl_pull_sample_l, liblsl), Cdouble, (lsl_inlet, Ptr{Clong}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
    end
end

function lsl_pull_sample_i(in, buffer, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_i, liblsl), Cdouble, (lsl_inlet, Ptr{Int32}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
end

function lsl_pull_sample_s(in, buffer, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_s, liblsl), Cdouble, (lsl_inlet, Ptr{Int16}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
end

function lsl_pull_sample_c(in, buffer, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_c, liblsl), Cdouble, (lsl_inlet, Ptr{Cchar}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
end

function lsl_pull_sample_str(in, buffer, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_str, liblsl), Cdouble, (lsl_inlet, Ptr{Cstring}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_elements, timeout, ec)
end

function lsl_pull_sample_buf(in, buffer, buffer_lengths, buffer_elements, timeout, ec)
    ccall((:lsl_pull_sample_buf, liblsl), Cdouble, (lsl_inlet, Ptr{Cstring}, Ptr{UInt32}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_lengths, buffer_elements, timeout, ec)
end

function lsl_pull_sample_v(in, buffer, buffer_bytes, timeout, ec)
    ccall((:lsl_pull_sample_v, liblsl), Cdouble, (lsl_inlet, Ptr{Cvoid}, Int32, Cdouble, Ptr{Int32}), in, buffer, buffer_bytes, timeout, ec)
end

function lsl_pull_chunk_f(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_f, liblsl), Culong, (lsl_inlet, Ptr{Cfloat}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

function lsl_pull_chunk_d(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_d, liblsl), Culong, (lsl_inlet, Ptr{Cdouble}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
    function lsl_pull_chunk_l(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
        ccall((:lsl_pull_chunk_l, liblsl), Culong, (lsl_inlet, Ptr{Clong}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    end
end

function lsl_pull_chunk_i(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_i, liblsl), Culong, (lsl_inlet, Ptr{Int32}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

function lsl_pull_chunk_s(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_s, liblsl), Culong, (lsl_inlet, Ptr{Int16}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

function lsl_pull_chunk_c(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_c, liblsl), Culong, (lsl_inlet, Ptr{Cchar}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

function lsl_pull_chunk_str(in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_str, liblsl), Culong, (lsl_inlet, Ptr{Cstring}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

function lsl_pull_chunk_buf(in, data_buffer, lengths_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
    ccall((:lsl_pull_chunk_buf, liblsl), Culong, (lsl_inlet, Ptr{Cstring}, Ptr{UInt32}, Ptr{Cdouble}, Culong, Culong, Cdouble, Ptr{Int32}), in, data_buffer, lengths_buffer, timestamp_buffer, data_buffer_elements, timestamp_buffer_elements, timeout, ec)
end

function lsl_samples_available(in)
    ccall((:lsl_samples_available, liblsl), UInt32, (lsl_inlet,), in)
end

function lsl_was_clock_reset(in)
    ccall((:lsl_was_clock_reset, liblsl), UInt32, (lsl_inlet,), in)
end

function lsl_smoothing_halftime(in, value)
    ccall((:lsl_smoothing_halftime, liblsl), Int32, (lsl_inlet, Cfloat), in, value)
end

function lsl_first_child(e)
    ccall((:lsl_first_child, liblsl), lsl_xml_ptr, (lsl_xml_ptr,), e)
end

function lsl_last_child(e)
    ccall((:lsl_last_child, liblsl), lsl_xml_ptr, (lsl_xml_ptr,), e)
end

function lsl_next_sibling(e)
    ccall((:lsl_next_sibling, liblsl), lsl_xml_ptr, (lsl_xml_ptr,), e)
end

function lsl_previous_sibling(e)
    ccall((:lsl_previous_sibling, liblsl), lsl_xml_ptr, (lsl_xml_ptr,), e)
end

function lsl_parent(e)
    ccall((:lsl_parent, liblsl), lsl_xml_ptr, (lsl_xml_ptr,), e)
end

function lsl_child(e, name)
    ccall((:lsl_child, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_next_sibling_n(e, name)
    ccall((:lsl_next_sibling_n, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_previous_sibling_n(e, name)
    ccall((:lsl_previous_sibling_n, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_empty(e)
    ccall((:lsl_empty, liblsl), Int32, (lsl_xml_ptr,), e)
end

function lsl_is_text(e)
    ccall((:lsl_is_text, liblsl), Int32, (lsl_xml_ptr,), e)
end

function lsl_name(e)
    ccall((:lsl_name, liblsl), Cstring, (lsl_xml_ptr,), e)
end

function lsl_value(e)
    ccall((:lsl_value, liblsl), Cstring, (lsl_xml_ptr,), e)
end

function lsl_child_value(e)
    ccall((:lsl_child_value, liblsl), Cstring, (lsl_xml_ptr,), e)
end

function lsl_child_value_n(e, name)
    ccall((:lsl_child_value_n, liblsl), Cstring, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_append_child_value(e, name, value)
    ccall((:lsl_append_child_value, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring, Cstring), e, name, value)
end

function lsl_prepend_child_value(e, name, value)
    ccall((:lsl_prepend_child_value, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring, Cstring), e, name, value)
end

function lsl_set_child_value(e, name, value)
    ccall((:lsl_set_child_value, liblsl), Int32, (lsl_xml_ptr, Cstring, Cstring), e, name, value)
end

function lsl_set_name(e, rhs)
    ccall((:lsl_set_name, liblsl), Int32, (lsl_xml_ptr, Cstring), e, rhs)
end

function lsl_set_value(e, rhs)
    ccall((:lsl_set_value, liblsl), Int32, (lsl_xml_ptr, Cstring), e, rhs)
end

function lsl_append_child(e, name)
    ccall((:lsl_append_child, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_prepend_child(e, name)
    ccall((:lsl_prepend_child, liblsl), lsl_xml_ptr, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_append_copy(e, e2)
    ccall((:lsl_append_copy, liblsl), lsl_xml_ptr, (lsl_xml_ptr, lsl_xml_ptr), e, e2)
end

function lsl_prepend_copy(e, e2)
    ccall((:lsl_prepend_copy, liblsl), lsl_xml_ptr, (lsl_xml_ptr, lsl_xml_ptr), e, e2)
end

function lsl_remove_child_n(e, name)
    ccall((:lsl_remove_child_n, liblsl), Cvoid, (lsl_xml_ptr, Cstring), e, name)
end

function lsl_remove_child(e, e2)
    ccall((:lsl_remove_child, liblsl), Cvoid, (lsl_xml_ptr, lsl_xml_ptr), e, e2)
end

function lsl_create_continuous_resolver(forget_after)
    ccall((:lsl_create_continuous_resolver, liblsl), lsl_continuous_resolver, (Cdouble,), forget_after)
end

function lsl_create_continuous_resolver_byprop(prop, value, forget_after)
    ccall((:lsl_create_continuous_resolver_byprop, liblsl), lsl_continuous_resolver, (Cstring, Cstring, Cdouble), prop, value, forget_after)
end

function lsl_create_continuous_resolver_bypred(pred, forget_after)
    ccall((:lsl_create_continuous_resolver_bypred, liblsl), lsl_continuous_resolver, (Cstring, Cdouble), pred, forget_after)
end

function lsl_resolver_results(res, buffer, buffer_elements)
    ccall((:lsl_resolver_results, liblsl), Int32, (lsl_continuous_resolver, Ptr{lsl_streaminfo}, UInt32), res, buffer, buffer_elements)
end

function lsl_destroy_continuous_resolver(res)
    ccall((:lsl_destroy_continuous_resolver, liblsl), Cvoid, (lsl_continuous_resolver,), res)
end
