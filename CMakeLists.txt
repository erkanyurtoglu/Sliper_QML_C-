cmake_minimum_required(VERSION 3.16)
project(sliper VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_PREFIX_PATH "C:/Qt/6.7.3/mingw_64")

find_package(Qt6 REQUIRED COMPONENTS Core Quick Charts Widgets Sql PrintSupport Network)

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
)

qt_add_qml_module(sliper
    URI sliper
    VERSION 1.0

    QML_FILES
        qml/Main.qml
        qml/pages/LoginPage.qml
        qml/pages/DashboardPage.qml
        qml/pages/OlcumPage.qml
        qml/pages/SonuclarPage.qml
        qml/pages/GecmisPage.qml
        qml/pages/KalibrasyonPage.qml

    RESOURCES
        qml/assets/logo.png
        qml/assets/egim_sensor.png
        qml/assets/loadcell.png
        qml/assets/mesafe_sensor.png
)

target_link_libraries(sliper PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Charts
    Qt6::Widgets
    Qt6::Sql
    Qt6::PrintSupport
    Qt6::Network
)