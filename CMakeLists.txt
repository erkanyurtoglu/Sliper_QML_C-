cmake_minimum_required(VERSION 3.16)
project(sliper VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_PREFIX_PATH "C:/Qt/6.7.3/mingw_64")

find_package(Qt6 REQUIRED COMPONENTS Core Quick Charts Widgets Sql PrintSupport Network Multimedia)

qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)

qt_add_executable(sliper
    main.cpp
    src/Backend.h
    src/Backend.cpp
    src/SensorManager.h
    src/SensorManager.cpp
    src/Calculator.h
    src/Calculator.cpp
    src/Database.h
    src/Database.cpp
    src/ReportManager.h
    src/ReportManager.cpp
    src/WifiManager.h
    src/WifiManager.cpp
    src/VoiceCommandManager.h
    src/VoiceCommandManager.cpp
    src/VoiceRecognitionWorker.h
    src/VoiceRecognitionWorker.cpp
)

set_source_files_properties(qml/Translations.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(sliper
    URI sliper
    VERSION 1.0

    QML_FILES
        qml/Main.qml
        qml/Translations.qml
        qml/pages/LoginPage.qml
        qml/pages/DashboardPage.qml
        qml/pages/OlcumPage.qml
        qml/pages/SonuclarPage.qml
        qml/pages/GecmisPage.qml
        qml/pages/KalibrasyonPage.qml
        qml/pages/RehberPage.qml
        qml/components/SuTerazisi.qml
        qml/components/TarihSecici.qml

    RESOURCES
        qml/assets/logo.png
        qml/assets/egim_sensor.png
        qml/assets/loadcell.png
        qml/assets/mesafe_sensor.png
        qml/assets/slipergif.mp4
)

target_link_libraries(sliper PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Charts
    Qt6::Widgets
    Qt6::Sql
    Qt6::PrintSupport
    Qt6::Network
    Qt6::Multimedia
)

# --- Sesli komut (Vosk, offline Turkce konusma tanima) ---
set(VOSK_DIR "${CMAKE_SOURCE_DIR}/third_party/vosk")
set(VOSK_MODEL_DIR "${CMAKE_SOURCE_DIR}/resources/vosk-model-small-tr-0.3")

target_include_directories(sliper PRIVATE ${VOSK_DIR})
target_link_libraries(sliper PRIVATE "${VOSK_DIR}/libvosk.lib")

# libvosk.dll kendi MinGW calisma zamanini (libstdc++/libwinpthread/libgcc_s)
# gerektirir. Vosk paketiyle gelen bu DLL'leri DEGIL, projenin kullandigi
# Qt MinGW derleyicisiyle ayni surumden gelenleri kopyaliyoruz; aksi halde
# surum uyusmazligi uygulamanin ENTRYPOINT_NOT_FOUND ile cokmesine yol acar.
get_filename_component(MINGW_BIN_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)

add_custom_command(TARGET sliper POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${VOSK_DIR}/libvosk.dll"
        "${MINGW_BIN_DIR}/libstdc++-6.dll"
        "${MINGW_BIN_DIR}/libwinpthread-1.dll"
        "${MINGW_BIN_DIR}/libgcc_s_seh-1.dll"
        "$<TARGET_FILE_DIR:sliper>"
    COMMENT "Vosk kutuphaneleri kopyalaniyor"
)

add_custom_command(TARGET sliper POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${VOSK_MODEL_DIR}"
        "$<TARGET_FILE_DIR:sliper>/vosk-model-small-tr-0.3"
    COMMENT "Vosk Turkce ses tanima modeli kopyalaniyor"
)