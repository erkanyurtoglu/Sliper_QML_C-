file(REMOVE_RECURSE
  "sliper/qml/Main.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/sliper_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
