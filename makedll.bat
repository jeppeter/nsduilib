mkdir build  || echo "build already exist"
pushd %CD%
(cd build && cmake ..\src) || echo "not run cmake right"
popd
cscript change_precomp.vbs build\duilib\duilib.vcxproj


