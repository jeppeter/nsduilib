1. 直接双击makeall.bat 
2. 在build\nsduilib\Release\nsduilib.dll就是生成的dll的文件
3. example\360Safe目录下的程序即为实例程序（360SafeSetup.exe安装包安装后的程序）；
4. example\setup res是安装包（360SafeSetup.exe）的资源；
5. example目录下basehelp.nsh nsduilib.nsh format.nsh valid.nsh algo.nsh 是公用脚本。

或者
1. 直接双击makedll.bat
2. 在build\nsduilib\Release\nsduilib.dll就生成dll文件

依赖条件：
 visual studio 2013或更新的版本 (已经支持visual studio 2017)
 cmake 3.8.0 或更新的版本
 nsis 3.0.2 或更新的版本
 git 2.0 或更新的版本

本软件最初由
TBCIA团队出品
联系方式：arbullzhang@gmail.com（阿牛）
               (qq:153139715)
后经jeppeter修正
联系方式: jeppeter@gmail.com

历史记录：
2017.11.16  增加了处理shortname变成longname的模式，参见InitTBCIASkinEngine