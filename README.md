架构设计：
相机类负责探测器参数，生成光线，光线追迹-光线颜色计算（包括设置最大散射光线生成次数，开始计算光线是否命中），使用hit_record类存储命中结果。接受参数hittable类（实际上为子类hittable_list，为渲染世界中所有可命中物体的集合，提供是否命中布尔函数，并在函数执行过程中实时修改hit_record信息）
hit_record类记录命中交点、交点法线与材质信息，在ray_color中判断是否散射并在函数中替换原光线为新散射光线




















PowerShell指令
将.exe 转成.ppm
注意！！！！！！！一定要用下面的代码（Windows PowerShell 对“外部程序输出”做重定向时，经常会用 Unicode(UTF-16LE) 写文件（而不是原始字节流），于是 PPM 被“变成 UTF-16 文本”。）
cmd /c ".\RayTracing.exe > image.ppm"   
将.ppm转成可查看的jpg
magick ppm:.\image.ppm .\image.png
