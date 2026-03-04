format long
clc

%% 1. 螺旋桨

% [TR1] = stlread('螺旋桨1.stl');
% 
% figure(1)
% trisurf(TR1);
% axis equal;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% 
% 
% figure(2)
% % 二维三角图
% triplot(TR)


%% 2. 3片镜子

% [TR2] = stlread('镜头3片.stl');
% 
% 
% 
% % figure(2)
% % trisurf(TR2);
% % axis equal;
% % xlabel('Z'); ylabel('Y'); zlabel('X');
% 
% % 定义射线参数
% rayOrigin = [0, 0, -15];   % 射线起点
% rayDir = [0, 0, 1];        % 射线方向  z轴
% 
% 
% % 计算交点
% [faces, points, Points_RemoveDuplicates] = rayTriIntersectionMT(rayOrigin, rayDir, TR2);
% 
% % 可视化结果
% figure(2)
% trisurf(TR2.ConnectivityList, TR2.Points(:,3), TR2.Points(:,2), TR2.Points(:,1), 'FaceAlpha', 0.8);
% hold on;
% plot3(rayOrigin(3), rayOrigin(2), rayOrigin(1), 'b', 'MarkerSize', 10);
% quiver3(rayOrigin(3), rayOrigin(2), rayOrigin(1),...
%         rayDir(3), rayDir(2), rayDir(1), 180, 'b', 'LineWidth', 2);
% if ~isempty(Points_RemoveDuplicates)
%     plot3(Points_RemoveDuplicates(:,3), Points_RemoveDuplicates(:,2), Points_RemoveDuplicates(:,1),...
%           'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
% end
% axis equal;
% xlabel('Z'); ylabel('Y'); zlabel('X');


%% 3. petzval透镜

% [TR3] = stlread('petzval透镜.stl');
% 
% 
% % 定义射线参数
% rayOrigin = [0, 0, -15];   % 射线起点
% rayDir = [0, 0, 1];        % 射线方向  z轴
% 
% 
% % 计算交点
% [faces, points, Points_RemoveDuplicates] = rayTriIntersectionMT(rayOrigin, rayDir, TR3);
% 
% % 可视化结果
% figure(3)
% trisurf(TR3.ConnectivityList, TR3.Points(:,3), TR3.Points(:,2), TR3.Points(:,1), 'FaceAlpha', 0.8);
% hold on;
% plot3(rayOrigin(3), rayOrigin(2), rayOrigin(1), 'b', 'MarkerSize', 10);
% quiver3(rayOrigin(3), rayOrigin(2), rayOrigin(1),...
%         rayDir(3), rayDir(2), rayDir(1), 180, 'b', 'LineWidth', 2);
% if ~isempty(Points_RemoveDuplicates)
%     plot3(Points_RemoveDuplicates(:,3), Points_RemoveDuplicates(:,2), Points_RemoveDuplicates(:,1),...
%           'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
% end
% axis equal;
% xlabel('Z'); ylabel('Y'); zlabel('X');



%% 4. 微光刻透镜

% % 读取STL文件
% [TR4] = stlread('microlithography_lens.stl');
% 
% % 定义射线参数
% rayOrigin = [0, 0, -100];   % 射线起点
% rayDir = [0, 0, 1];         % 射线方向
% 
% tic
% % 计算交点
% [faces, points, Points_RemoveDuplicates] = rayTriIntersectionMT(rayOrigin, rayDir, TR4);
% toc
% 
% 
% % 可视化结果
% figure(4)
% trisurf(TR4.ConnectivityList, TR4.Points(:,3), TR4.Points(:,2), TR4.Points(:,1), 'FaceAlpha', 0.8);
% hold on;
% plot3(rayOrigin(3), rayOrigin(2), rayOrigin(1), 'b', 'MarkerSize', 10);
% quiver3(rayOrigin(3), rayOrigin(2), rayOrigin(1),...
%         rayDir(3), rayDir(2), rayDir(1), 1200, 'b', 'LineWidth', 2);
% if ~isempty(Points_RemoveDuplicates)
%     plot3(Points_RemoveDuplicates(:,3), Points_RemoveDuplicates(:,2), Points_RemoveDuplicates(:,1),...
%           'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
% end
% axis equal;
% xlabel('Z'); ylabel('Y'); zlabel('X');



%% 5. 球

% % 球心(0,0,0) 半径10
% % 读取STL文件
% [TR5] = stlread('球1.stl');
% 
% % 计算法向量
% normals = faceNormal(TR5);
% 
% % 定义射线参数
% % rayOrigin = [0, 0, -15];   % 射线起点
% % rayDir = [0, 0, 1];        % 射线方向  z轴
% 
% rayOrigin = [-10, -10, -10];   % 射线起点
% rayDir = [1, 1, 1];        
% 
% % rayOrigin = [2, -0, 0];   % 射线起点
% % rayDir = [0, 0, 1]; 
% 
% % 计算交点
% [faces, points, Points_RemoveDuplicates, Normals_intersection] = rayTriIntersectionMT(rayOrigin, rayDir, TR5, normals);
% 
% % 可视化结果
% figure(5)
% trisurf(TR5, 'FaceAlpha', 0.8);
% hold on;
% plot3(rayOrigin(1), rayOrigin(2), rayOrigin(3), 'b', 'MarkerSize', 10);
% quiver3(rayOrigin(1), rayOrigin(2), rayOrigin(3),...
%         rayDir(1), rayDir(2), rayDir(3), 30, 'b', 'LineWidth', 2);
% if ~isempty(Points_RemoveDuplicates)
%     plot3(Points_RemoveDuplicates(:,1), Points_RemoveDuplicates(:,2), Points_RemoveDuplicates(:,3),...
%           'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
% end
% axis equal;


%% 6. Cooke镜子  Lighttools案例


% 读取STL文件
[TR6] = stlread('Cooke.stl');

% 获取顶点和面
vertices = TR6.Points;
Faces = TR6.ConnectivityList;

% 计算法向量
normals = faceNormal(TR6);


% 定义射线参数

rayOrigin = [0, 0, -15];   % 射线起点
rayDir = [0, 0, 1];      % 射线方向  z轴


% rayOrigin = [0, -1, -1];   % 射线起点
% rayDir = [0, 0, 1];      % 射线方向  和z轴平行


% 计算交点
[faces_intersection, points_intersection, Points_RemoveDuplicates, Normals_intersection] = rayTriIntersectionMT(rayOrigin, rayDir, TR6, normals);


if isempty(Points_RemoveDuplicates)
    disp('无交点');
else
    disp('交点坐标:');
    disp(Points_RemoveDuplicates);
    disp('交点处法向量:');
    disp(Normals_intersection);
end

% 可视化结果

% 图1 光线及交点
figure(1)
trisurf(TR6.ConnectivityList, TR6.Points(:,3), TR6.Points(:,2), TR6.Points(:,1), 'FaceAlpha', 0.8);
hold on;
plot3(rayOrigin(3), rayOrigin(2), rayOrigin(1), 'b', 'MarkerSize', 10);
quiver3(rayOrigin(3), rayOrigin(2), rayOrigin(1),...
        rayDir(3), rayDir(2), rayDir(1), 50, 'b', 'LineWidth', 2);
if ~isempty(Points_RemoveDuplicates)
    plot3(Points_RemoveDuplicates(:,3), Points_RemoveDuplicates(:,2), Points_RemoveDuplicates(:,1),...
          'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
end
axis equal;
title('光线及交点');
xlabel('Z'); ylabel('Y'); zlabel('X');
hold off;



% 图2 所有面片法向
figure(2)
% trisurf(faces, vertices(:,3), vertices(:,2), vertices(:,1), 'FaceAlpha', 0.5);


% 绘制法向量（红色）
faceCenters = (vertices(Faces(:,1),:) + vertices(Faces(:,2),:) + vertices(Faces(:,3),:)) / 3;
quiver3(faceCenters(:,3), faceCenters(:,2), faceCenters(:,1),...
        normals(:,3), normals(:,2), normals(:,1),...
        'r', 'LineWidth', 2, 'AutoScaleFactor', 0.5);

axis equal;
title('指向外的法向量验证');
xlabel('Z'); ylabel('Y'); zlabel('X');




%% 7. obj


% % 读取obj文件
% % 方式1
% [TR7_obj] = read_obj('model.obj');
% 
% P = TR7_obj.xyz';   % 顶点坐标
% T = TR7_obj.tri';
% 
% TR7 = triangulation(T,P);
% 
% % % 方式2 
% % % 简洁，只输出triangulation对象
% % TR7 = readObjToTriangulation('model.obj');
% 
% 
% % 计算三角面片的面法向量
% face_normals = faceNormal(TR7);
% 
% 
% % 方式3
% % [TR7, face_normals, obj] = load_obj_with_normals('model.obj');
% 
% 
% 
% % 获取顶点和面
% vertices = TR7.Points;
% Faces = TR7.ConnectivityList;
% 
% 
% % 定义射线参数
% % rayOrigin = [-1.5, 0, 0];   % 射线起点
% % rayDir = [1, 0, 0];        % 射线方向  x轴
% 
% rayOrigin = [-1.5, 0, 0];          % 射线起点
% rayDir = [2*sqrt(2)/3, 1/3, 0];    % 射线方向
% 
% 
% 
% % 计算交点
% [faces, points, Points_RemoveDuplicates, Normals_intersection] = rayTriIntersectionMT(rayOrigin, rayDir, TR7, face_normals);
% 
% % 可视化结果
% 
% % 图1 光线及交点
% figure(5)
% trisurf(TR7, 'FaceAlpha', 0.8);
% hold on;
% plot3(rayOrigin(1), rayOrigin(2), rayOrigin(3), 'b', 'MarkerSize', 10);
% quiver3(rayOrigin(1), rayOrigin(2), rayOrigin(3),...
%         rayDir(1), rayDir(2), rayDir(3), 5, 'b', 'LineWidth', 2);
% if ~isempty(Points_RemoveDuplicates)
%     plot3(Points_RemoveDuplicates(:,1), Points_RemoveDuplicates(:,2), Points_RemoveDuplicates(:,3),...
%           'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
% end
% axis equal;
% title('光线及交点');
% xlabel('Z'); ylabel('Y'); zlabel('X');
% hold off;
% 
% 
% % 图2 所有面片法向
% figure(6)
% % trisurf(faces, vertices(:,3), vertices(:,2), vertices(:,1), 'FaceAlpha', 0.5);
% 
% 
% % 绘制法向量（红色）
% faceCenters = (vertices(Faces(:,1),:) + vertices(Faces(:,2),:) + vertices(Faces(:,3),:)) / 3;
% quiver3(faceCenters(:,1), faceCenters(:,2), faceCenters(:,3),...
%         face_normals(:,1), face_normals(:,2), face_normals(:,3),...
%         'r', 'LineWidth', 2, 'AutoScaleFactor', 0.5);
% 
% axis equal;
% title('指向外的法向量验证');
% xlabel('Z'); ylabel('Y'); zlabel('X');


