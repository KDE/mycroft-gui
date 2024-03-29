project(mycroftimport)

set(mycroftimport_SRCS
    mycroftplugin.cpp
    mycroftcontroller.cpp
    activeskillsmodel.cpp
    delegatesmodel.cpp
    abstractskillview.cpp
    abstractdelegate.cpp
    sessiondatamap.cpp
    sessiondatamodel.cpp
    globalsettings.cpp
    filereader.cpp
    audiorec.cpp
    mediaservice.cpp
    thirdparty/fftcalc.cpp
    thirdparty/fft.cpp
    )

configure_file(controllerconfig.h.in ${CMAKE_CURRENT_BINARY_DIR}/controllerconfig.h)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

qt5_add_resources(mycroftimport_SRCS mycroft.qrc)

add_library(mycroftplugin SHARED ${mycroftimport_SRCS} ${RESOURCES})

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(mycroftplugin_EXTRA_LIBS
        Qt5::TextToSpeech
    )
endif()

target_link_libraries(mycroftplugin
        PUBLIC
            Qt5::Core
            Qt5::Multimedia
            ${mycroftplugin_EXTRA_LIBS}
        PRIVATE
            Qt5::Qml
            Qt5::Quick
            Qt5::Network
            Qt5::WebSockets
    )

install(TARGETS mycroftplugin DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)
install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/Mycroft)

