1. ֱ��˫��makeall.bat 
2. ��build\nsduilib\Release\nsduilib.dll�������ɵ�dll���ļ�
3. example\360SafeĿ¼�µĳ���Ϊʵ������360SafeSetup.exe��װ����װ��ĳ��򣩣�
4. example\setup res�ǰ�װ����360SafeSetup.exe������Դ��
5. exampleĿ¼��basehelp.nsh nsduilib.nsh format.nsh valid.nsh algo.nsh �ǹ��ýű���

����
1. ֱ��˫��makedll.bat
2. ��build\nsduilib\Release\nsduilib.dll������dll�ļ�

����������
 visual studio 2013����µİ汾 (�Ѿ�֧��visual studio 2017)
 nsis 3.0.2 ����µİ汾
 git 2.0 ����µİ汾

����������
TBCIA�Ŷӳ�Ʒ
��ϵ��ʽ��arbullzhang@gmail.com����ţ��
               (qq:153139715)
��jeppeter����
��ϵ��ʽ: jeppeter@gmail.com

��ʷ��¼��
2024.7.26   ����������һ������ѡ��NSDUILIB_UNICODE_STRING ���ļ�plugin.c �У���������� NSDUILIB_UNICODE_STRING== 1��ʾ֧��3.08�汾�Ժ�ģ���NSDUILIB_UNICODE_STRING == 0 ��ʾ֧��3.08�汾��ǰ�ģ���pluginsĿ¼��nsduilibw.dll��ʾ��֧��3.08�汾�Ժ�� nsduiliba.dll��ʾ3.08�汾��ǰ��
2017.11.16  �����˴���shortname���longname��ģʽ���μ�InitTBCIASkinEngine
2019.12.26  �Գ���ȥ����cmake��������ʹ��cl.exe link.exe��ֱ�ӱ���