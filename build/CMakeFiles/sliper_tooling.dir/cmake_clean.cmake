file(REMOVE_RECURSE
  "sliper/qml/Main.qml"
  "sliper/qml/assets/logo.png"
  "sliper/qml/pages/LoginPage.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/sliper_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
