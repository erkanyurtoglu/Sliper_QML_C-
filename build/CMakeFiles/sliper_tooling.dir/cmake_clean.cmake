file(REMOVE_RECURSE
  "sliper/qml/Main.qml"
  "sliper/qml/assets/logo.png"
  "sliper/qml/pages/DashboardPage.qml"
  "sliper/qml/pages/GecmisPage.qml"
  "sliper/qml/pages/KalibrasyonPage.qml"
  "sliper/qml/pages/LoginPage.qml"
  "sliper/qml/pages/OlcumPage.qml"
  "sliper/qml/pages/SonuclarPage.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/sliper_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
