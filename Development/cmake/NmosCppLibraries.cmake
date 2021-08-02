include(CMakeRegexEscape)

string(REGEX REPLACE ${REPLACE_MATCH} ${REPLACE_REPLACE} CMAKE_CURRENT_BINARY_DIR_REPLACE "${CMAKE_CURRENT_BINARY_DIR}")

# detail headers

set(DETAIL_HEADERS
    detail/default_init_allocator.h
    detail/for_each_reversed.h
    detail/pragma_warnings.h
    detail/private_access.h
    )

if(MSVC)
    list(APPEND DETAIL_HEADERS
        detail/vc_disable_dll_warnings.h
        detail/vc_disable_warnings.h
        )
endif()

install(FILES ${DETAIL_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/detail)

# slog library

# compile-time control of logging loquacity
# use slog::never_log_severity to strip all logging at compile-time, or slog::max_verbosity for full control at run-time
set(SLOG_LOGGING_SEVERITY slog::max_verbosity CACHE STRING "Compile-time logging level, e.g. between 40 (least verbose, only fatal messages) and -40 (most verbose)")

set(SLOG_HEADERS
    slog/all_in_one.h
    )

add_library(slog INTERFACE)

target_compile_definitions(
    slog INTERFACE
    SLOG_STATIC
    SLOG_LOGGING_SEVERITY=${SLOG_LOGGING_SEVERITY}
    )

if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
        target_compile_definitions(
            slog INTERFACE
            SLOG_DETAIL_NO_REF_QUALIFIERS
            )
    endif()
endif()

list(APPEND NMOS_CPP_TARGETS slog)
install(FILES ${SLOG_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/slog)

add_library(nmos-cpp::slog ALIAS slog)

# mDNS support library

set(MDNS_SOURCES
    mdns/core.cpp
    mdns/dns_sd_impl.cpp
    mdns/service_advertiser_impl.cpp
    mdns/service_discovery_impl.cpp
    )
set(MDNS_HEADERS
    mdns/core.h
    mdns/dns_sd_impl.h
    mdns/service_advertiser.h
    mdns/service_advertiser_impl.h
    mdns/service_discovery.h
    mdns/service_discovery_impl.h
    )

add_library(
    mdns STATIC
    ${MDNS_SOURCES}
    ${MDNS_HEADERS}
    )

source_group("mdns\\Source Files" FILES ${MDNS_SOURCES})
source_group("mdns\\Header Files" FILES ${MDNS_HEADERS})

target_link_libraries(
    mdns PUBLIC
    nmos-cpp::slog
    nmos-cpp::cpprestsdk
    nmos-cpp::Boost
    )
target_link_libraries(
    mdns PRIVATE
    nmos-cpp::DNSSD
    )
target_include_directories(mdns PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
    )

list(APPEND NMOS_CPP_TARGETS mdns)
install(FILES ${MDNS_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/mdns)

add_library(nmos-cpp::mdns ALIAS mdns)

# LLDP support library
if(BUILD_LLDP)
    set(LLDP_SOURCES
        lldp/lldp.cpp
        lldp/lldp_frame.cpp
        lldp/lldp_manager_impl.cpp
        )
    set(LLDP_HEADERS
        lldp/lldp.h
        lldp/lldp_frame.h
        lldp/lldp_manager.h
        )

    add_library(
        lldp STATIC
        ${LLDP_SOURCES}
        ${LLDP_HEADERS}
        )

    source_group("lldp\\Source Files" FILES ${LLDP_SOURCES})
    source_group("lldp\\Header Files" FILES ${LLDP_HEADERS})

    target_link_libraries(
        lldp PUBLIC
        nmos-cpp::slog
        nmos-cpp::cpprestsdk
        )
    # hmm, want a PRIVATE dependency on PCAP, but need its target_link_directories for wpcap on Windows
    target_link_libraries(
        lldp PUBLIC
        nmos-cpp::PCAP
        )
    target_link_libraries(
        lldp PRIVATE
        nmos-cpp::Boost
        )
    target_include_directories(lldp PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
        )
    target_compile_definitions(
        lldp INTERFACE
        HAVE_LLDP
        )

    list(APPEND NMOS_CPP_TARGETS lldp)
    install(FILES ${LLDP_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/lldp)

    add_library(nmos-cpp::lldp ALIAS lldp)
endif()

# nmos_is04_schemas library

set(NMOS_IS04_SCHEMAS_HEADERS
    nmos/is04_schemas/is04_schemas.h
    )

set(NMOS_IS04_V1_3_TAG v1.3.x)
set(NMOS_IS04_V1_2_TAG v1.2.x)
set(NMOS_IS04_V1_1_TAG v1.1.x)
set(NMOS_IS04_V1_0_TAG v1.0.x)

set(NMOS_IS04_V1_3_SCHEMAS_JSON
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/clock_internal.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/clock_ptp.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/device.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/devices.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/error.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flows.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_audio_coded.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_audio_raw.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_json_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_mux.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_sdianc_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_video.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_video_coded.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/flow_video_raw.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/node.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/nodeapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/nodeapi-receiver-target.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/nodes.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/queryapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/queryapi-subscription-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/queryapi-subscriptions-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/queryapi-subscriptions-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/queryapi-subscriptions-websocket.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receiver.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receivers.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receiver_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receiver_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receiver_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receiver_mux.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/receiver_video.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/registrationapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/registrationapi-health-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/registrationapi-resource-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/registrationapi-resource-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/resource_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/sender.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/senders.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/source.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/sources.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/source_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/source_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/source_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_3_TAG}/APIs/schemas/source_generic.json
    )

set(NMOS_IS04_V1_2_SCHEMAS_JSON
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/clock_internal.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/clock_ptp.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/device.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/devices.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/error.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flows.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_audio_coded.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_audio_raw.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_mux.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_sdianc_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_video.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_video_coded.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/flow_video_raw.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/node.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/nodeapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/nodeapi-receiver-target.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/nodes.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/queryapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/queryapi-subscription-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/queryapi-subscriptions-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/queryapi-subscriptions-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/queryapi-subscriptions-websocket.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receiver.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receivers.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receiver_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receiver_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receiver_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receiver_mux.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/receiver_video.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/registrationapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/registrationapi-health-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/registrationapi-resource-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/registrationapi-resource-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/resource_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/sender.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/senders.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/source.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/sources.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/source_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/source_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_2_TAG}/APIs/schemas/source_generic.json
    )

set(NMOS_IS04_V1_1_SCHEMAS_JSON
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/clock_internal.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/clock_ptp.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/device.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/devices.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/error.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flows.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_audio_coded.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_audio_raw.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_mux.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_sdianc_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_video.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_video_coded.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/flow_video_raw.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/node.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/nodeapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/nodeapi-receiver-target.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/nodes.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/queryapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/queryapi-subscription-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/queryapi-subscriptions-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/queryapi-subscriptions-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/queryapi-subscriptions-websocket.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receiver.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receivers.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receiver_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receiver_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receiver_data.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receiver_mux.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/receiver_video.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/registrationapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/registrationapi-health-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/registrationapi-resource-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/registrationapi-resource-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/resource_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/sender.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/senders.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/source.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/sources.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/source_audio.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/source_core.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_1_TAG}/APIs/schemas/source_generic.json
    )

set(NMOS_IS04_V1_0_SCHEMAS_JSON
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/device.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/devices.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/error.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/flow.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/flows.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/node.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/nodeapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/nodeapi-receiver-target.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/nodes.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/queryapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/queryapi-subscription-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/queryapi-subscriptions-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/queryapi-v1.0-subscriptions-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/queryapi-v1.0-subscriptions-websocket.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/receiver.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/receivers.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/registrationapi-base.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/registrationapi-health-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/registrationapi-resource-response.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/registrationapi-v1.0-resource-post-request.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/sender-target.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/sender.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/senders.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/source.json
    third_party/nmos-discovery-registration/${NMOS_IS04_V1_0_TAG}/APIs/schemas/sources.json
    )

set(NMOS_IS04_SCHEMAS_JSON_MATCH "third_party/nmos-discovery-registration/([^/]+)/APIs/schemas/([^;]+)\\.json")
set(NMOS_IS04_SCHEMAS_SOURCE_REPLACE "${CMAKE_CURRENT_BINARY_DIR_REPLACE}/nmos/is04_schemas/\\1/\\2.cpp")
string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS04_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS04_V1_3_SCHEMAS_SOURCES "${NMOS_IS04_V1_3_SCHEMAS_JSON}")
string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS04_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS04_V1_2_SCHEMAS_SOURCES "${NMOS_IS04_V1_2_SCHEMAS_JSON}")
string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS04_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS04_V1_1_SCHEMAS_SOURCES "${NMOS_IS04_V1_1_SCHEMAS_JSON}")
string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS04_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS04_V1_0_SCHEMAS_SOURCES "${NMOS_IS04_V1_0_SCHEMAS_JSON}")

foreach(JSON ${NMOS_IS04_V1_3_SCHEMAS_JSON} ${NMOS_IS04_V1_2_SCHEMAS_JSON} ${NMOS_IS04_V1_1_SCHEMAS_JSON} ${NMOS_IS04_V1_0_SCHEMAS_JSON})
    string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}" "${NMOS_IS04_SCHEMAS_SOURCE_REPLACE}" SOURCE "${JSON}")
    string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}" "\\1" NS "${JSON}")
    string(REGEX REPLACE "${NMOS_IS04_SCHEMAS_JSON_MATCH}" "\\2" VAR "${JSON}")
    string(MAKE_C_IDENTIFIER "${NS}" NS)
    string(MAKE_C_IDENTIFIER "${VAR}" VAR)

    file(WRITE "${SOURCE}.in" "\
// Auto-generated from: ${JSON}\n\
\n\
namespace nmos\n\
{\n\
    namespace is04_schemas\n\
    {\n\
        namespace ${NS}\n\
        {\n\
            const char* ${VAR} = R\"-auto-generated-(")

    file(READ "${JSON}" RAW)
    file(APPEND "${SOURCE}.in" "${RAW}")

    file(APPEND "${SOURCE}.in" ")-auto-generated-\";\n\
        }\n\
    }\n\
}\n")

    configure_file("${SOURCE}.in" "${SOURCE}" COPYONLY)
endforeach()

add_library(
    nmos_is04_schemas STATIC
    ${NMOS_IS04_SCHEMAS_HEADERS}
    ${NMOS_IS04_V1_3_SCHEMAS_SOURCES}
    ${NMOS_IS04_V1_2_SCHEMAS_SOURCES}
    ${NMOS_IS04_V1_1_SCHEMAS_SOURCES}
    ${NMOS_IS04_V1_0_SCHEMAS_SOURCES}
    )

source_group("nmos\\is04_schemas\\Header Files" FILES ${NMOS_IS04_SCHEMAS_HEADERS})
source_group("nmos\\is04_schemas\\${NMOS_IS04_V1_3_TAG}\\Source Files" FILES ${NMOS_IS04_V1_3_SCHEMAS_SOURCES})
source_group("nmos\\is04_schemas\\${NMOS_IS04_V1_2_TAG}\\Source Files" FILES ${NMOS_IS04_V1_2_SCHEMAS_SOURCES})
source_group("nmos\\is04_schemas\\${NMOS_IS04_V1_1_TAG}\\Source Files" FILES ${NMOS_IS04_V1_1_SCHEMAS_SOURCES})
source_group("nmos\\is04_schemas\\${NMOS_IS04_V1_0_TAG}\\Source Files" FILES ${NMOS_IS04_V1_0_SCHEMAS_SOURCES})

target_link_libraries(
    nmos_is04_schemas
    )
target_include_directories(nmos_is04_schemas PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
    )

list(APPEND NMOS_CPP_TARGETS nmos_is04_schemas)

add_library(nmos-cpp::nmos_is04_schemas ALIAS nmos_is04_schemas)

# nmos_is05_schemas library

set(NMOS_IS05_SCHEMAS_HEADERS
    nmos/is05_schemas/is05_schemas.h
    )

set(NMOS_IS05_V1_1_TAG v1.1.x)
set(NMOS_IS05_V1_0_TAG v1.0.x)

set(NMOS_IS05_V1_1_SCHEMAS_JSON
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/activation-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/activation-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/bulk-receiver-post-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/bulk-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/bulk-sender-post-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/connectionapi-base.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/connectionapi-bulk.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/connectionapi-receiver.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/connectionapi-sender.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/connectionapi-single.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/constraint-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/constraints-schema-mqtt.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/constraints-schema-rtp.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/constraints-schema-websocket.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/constraints-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/error.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver_transport_params.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver_transport_params_dash.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver_transport_params_ext.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver_transport_params_mqtt.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver_transport_params_rtp.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver_transport_params_websocket.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver-stage-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/receiver-transport-file.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender_transport_params.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender_transport_params_dash.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender_transport_params_ext.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender_transport_params_mqtt.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender_transport_params_rtp.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender_transport_params_websocket.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender-receiver-base.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/sender-stage-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_1_TAG}/APIs/schemas/transporttype-response-schema.json
    )

set(NMOS_IS05_V1_0_SCHEMAS_JSON
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/connectionapi-base.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/connectionapi-bulk.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/connectionapi-receiver.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/connectionapi-sender.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/connectionapi-single.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/error.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0_receiver_transport_params_dash.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0_receiver_transport_params_rtp.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0_sender_transport_params_dash.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0_sender_transport_params_rtp.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-activation-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-activation-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-bulk-receiver-post-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-bulk-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-bulk-sender-post-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-constraints-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-receiver-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-receiver-stage-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/sender-receiver-base.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-sender-response-schema.json
    third_party/nmos-device-connection-management/${NMOS_IS05_V1_0_TAG}/APIs/schemas/v1.0-sender-stage-schema.json
    )

set(NMOS_IS05_SCHEMAS_JSON_MATCH "third_party/nmos-device-connection-management/([^/]+)/APIs/schemas/([^;]+)\\.json")
set(NMOS_IS05_SCHEMAS_SOURCE_REPLACE "${CMAKE_CURRENT_BINARY_DIR_REPLACE}/nmos/is05_schemas/\\1/\\2.cpp")
string(REGEX REPLACE "${NMOS_IS05_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS05_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS05_V1_1_SCHEMAS_SOURCES "${NMOS_IS05_V1_1_SCHEMAS_JSON}")
string(REGEX REPLACE "${NMOS_IS05_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS05_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS05_V1_0_SCHEMAS_SOURCES "${NMOS_IS05_V1_0_SCHEMAS_JSON}")

foreach(JSON ${NMOS_IS05_V1_1_SCHEMAS_JSON} ${NMOS_IS05_V1_0_SCHEMAS_JSON})
    string(REGEX REPLACE "${NMOS_IS05_SCHEMAS_JSON_MATCH}" "${NMOS_IS05_SCHEMAS_SOURCE_REPLACE}" SOURCE "${JSON}")
    string(REGEX REPLACE "${NMOS_IS05_SCHEMAS_JSON_MATCH}" "\\1" NS "${JSON}")
    string(REGEX REPLACE "${NMOS_IS05_SCHEMAS_JSON_MATCH}" "\\2" VAR "${JSON}")
    string(MAKE_C_IDENTIFIER "${NS}" NS)
    string(MAKE_C_IDENTIFIER "${VAR}" VAR)

    file(WRITE "${SOURCE}.in" "\
// Auto-generated from: ${JSON}\n\
\n\
namespace nmos\n\
{\n\
    namespace is05_schemas\n\
    {\n\
        namespace ${NS}\n\
        {\n\
            const char* ${VAR} = R\"-auto-generated-(")

    file(READ "${JSON}" RAW)
    file(APPEND "${SOURCE}.in" "${RAW}")

    file(APPEND "${SOURCE}.in" ")-auto-generated-\";\n\
        }\n\
    }\n\
}\n")

    configure_file("${SOURCE}.in" "${SOURCE}" COPYONLY)
endforeach()

add_library(
    nmos_is05_schemas STATIC
    ${NMOS_IS05_SCHEMAS_HEADERS}
    ${NMOS_IS05_V1_1_SCHEMAS_SOURCES}
    ${NMOS_IS05_V1_0_SCHEMAS_SOURCES}
    )

source_group("nmos\\is05_schemas\\Header Files" FILES ${NMOS_IS05_SCHEMAS_HEADERS})
source_group("nmos\\is05_schemas\\${NMOS_IS05_V1_1_TAG}\\Source Files" FILES ${NMOS_IS05_V1_1_SCHEMAS_SOURCES})
source_group("nmos\\is05_schemas\\${NMOS_IS05_V1_0_TAG}\\Source Files" FILES ${NMOS_IS05_V1_0_SCHEMAS_SOURCES})

target_link_libraries(
    nmos_is05_schemas
    )
target_include_directories(nmos_is05_schemas PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
    )

list(APPEND NMOS_CPP_TARGETS nmos_is05_schemas)

add_library(nmos-cpp::nmos_is05_schemas ALIAS nmos_is05_schemas)

# nmos_is08_schemas library

set(NMOS_IS08_SCHEMAS_HEADERS
    nmos/is08_schemas/is08_schemas.h
    )

set(NMOS_IS08_V1_0_TAG v1.0.x)

set(NMOS_IS08_V1_0_SCHEMAS_JSON
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/activation-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/activation-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/base-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/error.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/input-base-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/input-caps-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/input-channels-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/input-parent-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/input-properties-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/inputs-outputs-base-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/io-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-activations-activation-get-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-activations-get-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-activations-post-request-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-activations-post-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-active-output-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-active-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-base-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/map-entries-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/output-base-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/output-caps-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/output-channels-response-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/output-properties-schema.json
    third_party/nmos-audio-channel-mapping/${NMOS_IS08_V1_0_TAG}/APIs/schemas/output-sourceid-response-schema.json
    )

set(NMOS_IS08_SCHEMAS_JSON_MATCH "third_party/nmos-audio-channel-mapping/([^/]+)/APIs/schemas/([^;]+)\\.json")
set(NMOS_IS08_SCHEMAS_SOURCE_REPLACE "${CMAKE_CURRENT_BINARY_DIR_REPLACE}/nmos/is08_schemas/\\1/\\2.cpp")
string(REGEX REPLACE "${NMOS_IS08_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS08_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS08_V1_0_SCHEMAS_SOURCES "${NMOS_IS08_V1_0_SCHEMAS_JSON}")

foreach(JSON ${NMOS_IS08_V1_0_SCHEMAS_JSON})
    string(REGEX REPLACE "${NMOS_IS08_SCHEMAS_JSON_MATCH}" "${NMOS_IS08_SCHEMAS_SOURCE_REPLACE}" SOURCE "${JSON}")
    string(REGEX REPLACE "${NMOS_IS08_SCHEMAS_JSON_MATCH}" "\\1" NS "${JSON}")
    string(REGEX REPLACE "${NMOS_IS08_SCHEMAS_JSON_MATCH}" "\\2" VAR "${JSON}")
    string(MAKE_C_IDENTIFIER "${NS}" NS)
    string(MAKE_C_IDENTIFIER "${VAR}" VAR)

    file(WRITE "${SOURCE}.in" "\
// Auto-generated from: ${JSON}\n\
\n\
namespace nmos\n\
{\n\
    namespace is08_schemas\n\
    {\n\
        namespace ${NS}\n\
        {\n\
            const char* ${VAR} = R\"-auto-generated-(")

    file(READ "${JSON}" RAW)
    file(APPEND "${SOURCE}.in" "${RAW}")

    file(APPEND "${SOURCE}.in" ")-auto-generated-\";\n\
        }\n\
    }\n\
}\n")

    configure_file("${SOURCE}.in" "${SOURCE}" COPYONLY)
endforeach()

add_library(
    nmos_is08_schemas STATIC
    ${NMOS_IS08_SCHEMAS_HEADERS}
    ${NMOS_IS08_V1_0_SCHEMAS_SOURCES}
    )

source_group("nmos\\is08_schemas\\Header Files" FILES ${NMOS_IS08_SCHEMAS_HEADERS})
source_group("nmos\\is08_schemas\\${NMOS_IS08_V1_0_TAG}\\Source Files" FILES ${NMOS_IS08_V1_0_SCHEMAS_SOURCES})

target_link_libraries(
    nmos_is08_schemas
    )
target_include_directories(nmos_is08_schemas PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
    )

list(APPEND NMOS_CPP_TARGETS nmos_is08_schemas)

add_library(nmos-cpp::nmos_is08_schemas ALIAS nmos_is08_schemas)

# nmos_is09_schemas library

set(NMOS_IS09_SCHEMAS_HEADERS
    nmos/is09_schemas/is09_schemas.h
    )

set(NMOS_IS09_V1_0_TAG v1.0.x)

set(NMOS_IS09_V1_0_SCHEMAS_JSON
    third_party/nmos-system/${NMOS_IS09_V1_0_TAG}/APIs/schemas/base.json
    third_party/nmos-system/${NMOS_IS09_V1_0_TAG}/APIs/schemas/error.json
    third_party/nmos-system/${NMOS_IS09_V1_0_TAG}/APIs/schemas/global.json
    third_party/nmos-system/${NMOS_IS09_V1_0_TAG}/APIs/schemas/resource_core.json
    )

set(NMOS_IS09_SCHEMAS_JSON_MATCH "third_party/nmos-system/([^/]+)/APIs/schemas/([^;]+)\\.json")
set(NMOS_IS09_SCHEMAS_SOURCE_REPLACE "${CMAKE_CURRENT_BINARY_DIR_REPLACE}/nmos/is09_schemas/\\1/\\2.cpp")
string(REGEX REPLACE "${NMOS_IS09_SCHEMAS_JSON_MATCH}(;|$)" "${NMOS_IS09_SCHEMAS_SOURCE_REPLACE}\\3" NMOS_IS09_V1_0_SCHEMAS_SOURCES "${NMOS_IS09_V1_0_SCHEMAS_JSON}")

foreach(JSON ${NMOS_IS09_V1_0_SCHEMAS_JSON})
    string(REGEX REPLACE "${NMOS_IS09_SCHEMAS_JSON_MATCH}" "${NMOS_IS09_SCHEMAS_SOURCE_REPLACE}" SOURCE "${JSON}")
    string(REGEX REPLACE "${NMOS_IS09_SCHEMAS_JSON_MATCH}" "\\1" NS "${JSON}")
    string(REGEX REPLACE "${NMOS_IS09_SCHEMAS_JSON_MATCH}" "\\2" VAR "${JSON}")
    string(MAKE_C_IDENTIFIER "${NS}" NS)
    string(MAKE_C_IDENTIFIER "${VAR}" VAR)

    file(WRITE "${SOURCE}.in" "\
// Auto-generated from: ${JSON}\n\
\n\
namespace nmos\n\
{\n\
    namespace is09_schemas\n\
    {\n\
        namespace ${NS}\n\
        {\n\
            const char* ${VAR} = R\"-auto-generated-(")

    file(READ "${JSON}" RAW)
    file(APPEND "${SOURCE}.in" "${RAW}")

    file(APPEND "${SOURCE}.in" ")-auto-generated-\";\n\
        }\n\
    }\n\
}\n")

    configure_file("${SOURCE}.in" "${SOURCE}" COPYONLY)
endforeach()

add_library(
    nmos_is09_schemas STATIC
    ${NMOS_IS09_SCHEMAS_HEADERS}
    ${NMOS_IS09_V1_0_SCHEMAS_SOURCES}
    )

source_group("nmos\\is09_schemas\\Header Files" FILES ${NMOS_IS09_SCHEMAS_HEADERS})
source_group("nmos\\is09_schemas\\${NMOS_IS09_V1_0_TAG}\\Source Files" FILES ${NMOS_IS09_V1_0_SCHEMAS_SOURCES})

target_link_libraries(
    nmos_is09_schemas
    )
target_include_directories(nmos_is09_schemas PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
    )

list(APPEND NMOS_CPP_TARGETS nmos_is09_schemas)

add_library(nmos-cpp::nmos_is09_schemas ALIAS nmos_is09_schemas)

# json schema validator library

set(JSON_SCHEMA_VALIDATOR_SOURCES
    third_party/nlohmann/json-patch.cpp
    third_party/nlohmann/json-schema-draft7.json.cpp
    third_party/nlohmann/json-validator.cpp
    third_party/nlohmann/json-uri.cpp
    )

set(JSON_SCHEMA_VALIDATOR_HEADERS
    third_party/nlohmann/json-patch.hpp
    third_party/nlohmann/json-schema.hpp
    third_party/nlohmann/json.hpp
    )

add_library(
    json_schema_validator STATIC
    ${JSON_SCHEMA_VALIDATOR_SOURCES}
    ${JSON_SCHEMA_VALIDATOR_HEADERS}
    )

source_group("Source Files" FILES ${JSON_SCHEMA_VALIDATOR_SOURCES})
source_group("Header Files" FILES ${JSON_SCHEMA_VALIDATOR_HEADERS})

if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
        target_compile_definitions(
            json_schema_validator PRIVATE
            JSON_SCHEMA_BOOST_REGEX
            )
    endif()
endif()

target_link_libraries(
    json_schema_validator
    )
target_include_directories(json_schema_validator PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/third_party>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/third_party>
    )

list(APPEND NMOS_CPP_TARGETS json_schema_validator)

add_library(nmos-cpp::json_schema_validator ALIAS json_schema_validator)

# nmos-cpp library

set(NMOS_CPP_BST_SOURCES
    )
set(NMOS_CPP_BST_HEADERS
    bst/filesystem.h
    bst/optional.h
    bst/regex.h
    bst/shared_mutex.h
    )

set(NMOS_CPP_CPPREST_SOURCES
    cpprest/api_router.cpp
    cpprest/host_utils.cpp
    cpprest/http_utils.cpp
    cpprest/json_escape.cpp
    cpprest/json_storage.cpp
    cpprest/json_utils.cpp
    cpprest/json_validator_impl.cpp
    cpprest/json_visit.cpp
    cpprest/ws_listener_impl.cpp
    )

if(MSVC)
    # workaround for "fatal error C1128: number of sections exceeded object file format limit: compile with /bigobj"
    set_source_files_properties(cpprest/ws_listener_impl.cpp PROPERTIES COMPILE_FLAGS /bigobj)
endif()

set(NMOS_CPP_CPPREST_HEADERS
    cpprest/api_router.h
    cpprest/basic_utils.h
    cpprest/host_utils.h
    cpprest/http_utils.h
    cpprest/json_escape.h
    cpprest/json_ops.h
    cpprest/json_storage.h
    cpprest/json_utils.h
    cpprest/json_validator.h
    cpprest/json_visit.h
    cpprest/logging_utils.h
    cpprest/regex_utils.h
    cpprest/uri_schemes.h
    cpprest/ws_listener.h
    cpprest/ws_utils.h
    )

set(NMOS_CPP_CPPREST_DETAILS_HEADERS
    cpprest/details/boost_u_workaround.h
    cpprest/details/pop_u.h
    cpprest/details/push_undef_u.h
    cpprest/details/system_error.h
    )

set(NMOS_CPP_NMOS_SOURCES
    nmos/activation_utils.cpp
    nmos/admin_ui.cpp
    nmos/api_downgrade.cpp
    nmos/api_utils.cpp
    nmos/capabilities.cpp
    nmos/certificate_handlers.cpp
    nmos/channelmapping_activation.cpp
    nmos/channelmapping_api.cpp
    nmos/channelmapping_resources.cpp
    nmos/channels.cpp
    nmos/client_utils.cpp
    nmos/components.cpp
    nmos/connection_activation.cpp
    nmos/connection_api.cpp
    nmos/connection_events_activation.cpp
    nmos/connection_resources.cpp
    nmos/did_sdid.cpp
    nmos/events_api.cpp
    nmos/events_resources.cpp
    nmos/events_ws_api.cpp
    nmos/events_ws_client.cpp
    nmos/filesystem_route.cpp
    nmos/group_hint.cpp
    nmos/id.cpp
    nmos/lldp_handler.cpp
    nmos/lldp_manager.cpp
    nmos/json_schema.cpp
    nmos/log_model.cpp
    nmos/logging_api.cpp
    nmos/manifest_api.cpp
    nmos/mdns.cpp
    nmos/mdns_api.cpp
    nmos/node_api.cpp
    nmos/node_api_target_handler.cpp
    nmos/node_behaviour.cpp
    nmos/node_interfaces.cpp
    nmos/node_resource.cpp
    nmos/node_resources.cpp
    nmos/node_server.cpp
    nmos/node_system_behaviour.cpp
    nmos/process_utils.cpp
    nmos/query_api.cpp
    nmos/query_utils.cpp
    nmos/query_ws_api.cpp
    nmos/rational.cpp
    nmos/registration_api.cpp
    nmos/registry_resources.cpp
    nmos/registry_server.cpp
    nmos/resource.cpp
    nmos/resources.cpp
    nmos/schemas_api.cpp
    nmos/sdp_utils.cpp
    nmos/server.cpp
    nmos/server_utils.cpp
    nmos/settings.cpp
    nmos/settings_api.cpp
    nmos/system_api.cpp
    nmos/system_resources.cpp
    )
set(NMOS_CPP_NMOS_HEADERS
    nmos/activation_mode.h
    nmos/activation_utils.h
    nmos/admin_ui.h
    nmos/api_downgrade.h
    nmos/api_utils.h
    nmos/api_version.h
    nmos/capabilities.h
    nmos/certificate_handlers.h
    nmos/certificate_settings.h
    nmos/channelmapping_activation.h
    nmos/channelmapping_api.h
    nmos/channelmapping_resources.h
    nmos/channels.h
    nmos/client_utils.h
    nmos/clock_name.h
    nmos/clock_ref_type.h
    nmos/colorspace.h
    nmos/components.h
    nmos/copyable_atomic.h
    nmos/connection_activation.h
    nmos/connection_api.h
    nmos/connection_events_activation.h
    nmos/connection_resources.h
    nmos/device_type.h
    nmos/did_sdid.h
    nmos/event_type.h
    nmos/events_api.h
    nmos/events_resources.h
    nmos/events_ws_api.h
    nmos/events_ws_client.h
    nmos/filesystem_route.h
    nmos/format.h
    nmos/group_hint.h
    nmos/health.h
    nmos/id.h
    nmos/interlace_mode.h
    nmos/is04_versions.h
    nmos/is05_versions.h
    nmos/is07_versions.h
    nmos/is08_versions.h
    nmos/is09_versions.h
    nmos/json_fields.h
    nmos/json_schema.h
    nmos/lldp_handler.h
    nmos/lldp_manager.h
    nmos/log_gate.h
    nmos/log_manip.h
    nmos/log_model.h
    nmos/logging_api.h
    nmos/manifest_api.h
    nmos/mdns.h
    nmos/mdns_api.h
    nmos/mdns_versions.h
    nmos/media_type.h
    nmos/model.h
    nmos/mutex.h
    nmos/node_api.h
    nmos/node_api_target_handler.h
    nmos/node_behaviour.h
    nmos/node_interfaces.h
    nmos/node_resource.h
    nmos/node_resources.h
    nmos/node_server.h
    nmos/node_system_behaviour.h
    nmos/paging_utils.h
    nmos/process_utils.h
    nmos/query_api.h
    nmos/query_utils.h
    nmos/query_ws_api.h
    nmos/random.h
    nmos/rational.h
    nmos/registration_api.h
    nmos/registry_resources.h
    nmos/registry_server.h
    nmos/resource.h
    nmos/resources.h
    nmos/schemas_api.h
    nmos/sdp_utils.h
    nmos/server.h
    nmos/server_utils.h
    nmos/settings.h
    nmos/settings_api.h
    nmos/slog.h
    nmos/ssl_context_options.h
    nmos/string_enum.h
    nmos/system_api.h
    nmos/system_resources.h
    nmos/tai.h
    nmos/thread_utils.h
    nmos/transfer_characteristic.h
    nmos/transport.h
    nmos/type.h
    nmos/version.h
    nmos/vpid_code.h
    nmos/websockets.h
    )

set(NMOS_CPP_PPLX_SOURCES
    pplx/pplx_utils.cpp
    )
set(NMOS_CPP_PPLX_HEADERS
    pplx/pplx_utils.h
    )

set(NMOS_CPP_RQL_SOURCES
    rql/rql.cpp
    )
set(NMOS_CPP_RQL_HEADERS
    rql/rql.h
    )

set(NMOS_CPP_SDP_SOURCES
    sdp/sdp_grammar.cpp
    )
set(NMOS_CPP_SDP_HEADERS
    sdp/json.h
    sdp/ntp.h
    sdp/sdp.h
    sdp/sdp_grammar.h
    )

add_library(
    nmos-cpp STATIC
    ${NMOS_CPP_BST_SOURCES}
    ${NMOS_CPP_BST_HEADERS}
    ${NMOS_CPP_CPPREST_SOURCES}
    ${NMOS_CPP_CPPREST_HEADERS}
    ${NMOS_CPP_NMOS_SOURCES}
    ${NMOS_CPP_NMOS_HEADERS}
    ${NMOS_CPP_PPLX_SOURCES}
    ${NMOS_CPP_PPLX_HEADERS}
    ${NMOS_CPP_RQL_SOURCES}
    ${NMOS_CPP_RQL_HEADERS}
    ${NMOS_CPP_SDP_SOURCES}
    ${NMOS_CPP_SDP_HEADERS}
    )

source_group("bst\\Source Files" FILES ${NMOS_CPP_BST_SOURCES})
source_group("cpprest\\Source Files" FILES ${NMOS_CPP_CPPREST_SOURCES})
source_group("nmos\\Source Files" FILES ${NMOS_CPP_NMOS_SOURCES})
source_group("pplx\\Source Files" FILES ${NMOS_CPP_PPLX_SOURCES})
source_group("rql\\Source Files" FILES ${NMOS_CPP_RQL_SOURCES})
source_group("sdp\\Source Files" FILES ${NMOS_CPP_SDP_SOURCES})

source_group("bst\\Header Files" FILES ${NMOS_CPP_BST_HEADERS})
source_group("cpprest\\Header Files" FILES ${NMOS_CPP_CPPREST_HEADERS})
source_group("nmos\\Header Files" FILES ${NMOS_CPP_NMOS_HEADERS})
source_group("pplx\\Header Files" FILES ${NMOS_CPP_PPLX_HEADERS})
source_group("rql\\Header Files" FILES ${NMOS_CPP_RQL_HEADERS})
source_group("sdp\\Header Files" FILES ${NMOS_CPP_SDP_HEADERS})

target_link_libraries(
    nmos-cpp PUBLIC
    nmos-cpp::mdns
    nmos-cpp::slog
    nmos-cpp::cpprestsdk
    nmos-cpp::nmos_is04_schemas
    nmos-cpp::nmos_is05_schemas
    nmos-cpp::nmos_is08_schemas
    nmos-cpp::nmos_is09_schemas
    nmos-cpp::Boost
    nmos-cpp::OpenSSL
    )
target_link_libraries(
    nmos-cpp PRIVATE
    nmos-cpp::websocketpp
    nmos-cpp::json_schema_validator
    )
if(BUILD_LLDP)
    target_link_libraries(
        nmos-cpp PUBLIC
        nmos-cpp::lldp
        )
endif()
if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    # link to resolver functions (for cpprest/host_utils.cpp)
    # note: this is no longer required on all platforms
    target_link_libraries(
        nmos-cpp PUBLIC
        resolv
        )
    if((CMAKE_CXX_COMPILER_ID MATCHES GNU) AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 5.3))
        # link to std::filesystem functions (for bst/filesystem.h, used by nmos/filesystem_route.cpp)
        target_link_libraries(
            nmos-cpp PUBLIC
            stdc++fs
            )
    endif()
endif()
target_include_directories(nmos-cpp PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}>
    )

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    # Conan packages usually don't include PDB files so suppress the resulting warning
    # which is otherwise reported more than 500 times (across cpprest.pdb, ossl_static.pdb and zlibstatic.pdb)
    # when linking to nmos-cpp and its dependencies
    # see https://github.com/conan-io/conan-center-index/blob/master/docs/faqs.md#why-pdb-files-are-not-allowed
    # and https://github.com/conan-io/conan-center-index/issues/1982
    target_link_options(
        nmos-cpp INTERFACE
        /ignore:4099
        )
endif()

list(APPEND NMOS_CPP_TARGETS nmos-cpp)
install(FILES ${NMOS_CPP_BST_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/bst)
install(FILES ${NMOS_CPP_CPPREST_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/cpprest)
install(FILES ${NMOS_CPP_CPPREST_DETAILS_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/cpprest/details)
install(FILES ${NMOS_CPP_NMOS_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/nmos)
install(FILES ${NMOS_CPP_PPLX_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/pplx)
install(FILES ${NMOS_CPP_RQL_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/rql)
install(FILES ${NMOS_CPP_SDP_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}${NMOS_CPP_INCLUDE_PREFIX}/sdp)

add_library(nmos-cpp::nmos-cpp ALIAS nmos-cpp)
