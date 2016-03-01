1. 在src目录下，运行makedll.bat ，请确保已经安装了cmake程序，并且cmake.exe在可以查找的Path里面，运行程序,会生成一个build目录，在build目录下双击nsduilib.sln文件，选择生成Release 如果不是Release，那整个程序，会在没有安装程序的环境中运行失败
2. example目录下360SafeSetup.nsi是nsis示例脚本， 运行copymake.bat即可编译，会生成一个安装包（360SafeSetup.exe）；
3. example\360Safe目录下的程序即为实例程序（360SafeSetup.exe安装包安装后的程序）；
4. example\setup res是安装包（360SafeSetup.exe）的资源；
5. example目录下basehelp.nsh nsduilib.nsh format.nsh valid.nsh algo.nsh 是公用脚本。

本软件最初由
TBCIA团队出品
联系方式：arbullzhang@gmail.com（阿牛）
               (qq:153139715)
后经jeppeter修正
联系方式: jeppeter@gmail.com