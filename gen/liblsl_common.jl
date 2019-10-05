# Automatically generated using Clang.jl


const LSL_IRREGULAR_RATE = 0.0
const LSL_DEDUCED_TIMESTAMP = -1.0
const LSL_FOREVER = 3.2e7
const LSL_NO_PREFERENCE = 0

@cenum lsl_channel_format_t::UInt32 begin
    cft_float32 = 1
    cft_double64 = 2
    cft_string = 3
    cft_int32 = 4
    cft_int16 = 5
    cft_int8 = 6
    cft_int64 = 7
    cft_undefined = 0
end

@cenum lsl_processing_options_t::UInt32 begin
    proc_none = 0
    proc_clocksync = 1
    proc_dejitter = 2
    proc_monotonize = 4
    proc_threadsafe = 8
    proc_ALL = 15
end

@cenum lsl_error_code_t::Int32 begin
    lsl_no_error = 0
    lsl_timeout_error = -1
    lsl_lost_error = -2
    lsl_argument_error = -3
    lsl_internal_error = -4
end


# Skipping MacroDefinition: LIBLSL_C_API __attribute__ ( ( visibility ( "default" ) ) )
# Skipping MacroDefinition: LIBLSL_COMPILE_HEADER_VERSION = 113 ;

const lsl_streaminfo_struct_ = Cvoid
const lsl_streaminfo = Ptr{lsl_streaminfo_struct_}
const lsl_outlet_struct_ = Cvoid
const lsl_outlet = Ptr{lsl_outlet_struct_}
const lsl_inlet_struct_ = Cvoid
const lsl_inlet = Ptr{lsl_inlet_struct_}
const lsl_xml_ptr_struct_ = Cvoid
const lsl_xml_ptr = Ptr{lsl_xml_ptr_struct_}
const lsl_continuous_resolver_ = Cvoid
const lsl_continuous_resolver = Ptr{lsl_continuous_resolver_}
