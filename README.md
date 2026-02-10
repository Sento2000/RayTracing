PowerShell指令
将.exe 转成.ppm
注意！！！！！！！一定要用下面的代码（Windows PowerShell 对“外部程序输出”做重定向时，经常会用 Unicode(UTF-16LE) 写文件（而不是原始字节流），于是 PPM 被“变成 UTF-16 文本”。）
cmd /c ".\RayTracing.exe > image.ppm"   
将.ppm转成可查看的jpg
magick ppm:.\image.ppm .\image.png
