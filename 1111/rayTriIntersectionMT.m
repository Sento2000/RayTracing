function [intersectFaces, intersectPoints, intersectPoints_RemoveDuplicates, intersectNormals_RemoveDuplicates] = rayTriIntersectionMT(rayOrigin, rayDir, triObject, normals)
% 输入参数：
%   rayOrigin: 射线起点 [1x3]
%   rayDir: 射线方向[1x3]
%   triObject: triangulation 对象
%   normals:  面法向量(指向体外)
% 输出参数：
%   intersectFaces: 相交三角面元索引 [Kx1]
%   intersectPoints: 交点坐标 [Kx3] (有重复 eg:光线穿过几个面元的公共顶点/公共边)
%   intersectPoints_RemoveDuplicates: 交点坐标去重
%   intersectNormals_RemoveDuplicates: 交点(去重后)处法向量 


% 浮点误差
epsilon = 1e-13;

% 射线方向归一化
rayDir = rayDir/norm(rayDir);

% 提取三角面元顶点数据
vertices = triObject.Points;        % [Nx3]      N个节点     三角剖分点坐标(每个行号是一个顶点ID)  
faces = triObject.ConnectivityList; % [Mx3]      M个三角形   三角剖分连接列表(每个元素是顶点ID)

% 计算三角形数量
[num_tri,~] = size(faces);

% 射线方向 (扩展成M行)
rayDir_M = rayDir .* ones(num_tri, 1);


% 获取每个三角面元的三个顶点坐标
v0 = vertices(faces(:,1), :); % [Mx3]
v1 = vertices(faces(:,2), :); % [Mx3]
v2 = vertices(faces(:,3), :); % [Mx3]

% 计算三角形边向量
e1 = v1 - v0; % [Mx3]
e2 = v2 - v0; % [Mx3]

% 计算射线方向与e2的叉乘 (rayDir x e2)
p = cross(rayDir_M, e2, 2); % [Mx3]

% 计算行列式 (det = e1 ⋅ p)
det = dot(e1, p, 2); % [Mx1]

% 处理行列式接近零的情况（平行或退化的三角形）
validFaces = abs(det) > epsilon; % [Mx1] 逻辑索引

% 提前剔除无效面元
v0 = v0(validFaces, :);
% v1 = v1(validFaces, :);
% v2 = v2(validFaces, :);
e1 = e1(validFaces, :);
e2 = e2(validFaces, :);
p = p(validFaces, :);
det = det(validFaces);

originalFaceIndices = find(validFaces); % 记录原始面元索引

% 计算从v0到射线起点的向量
tVec = rayOrigin - v0; % [K1x3], K1=sum(validFaces)

% 计算u参数 (u = (tVec ⋅ p) / det)
u = dot(tVec, p, 2) ./ det; % [K1x1]

% 剔除u不在[0,1]区间的面元
validU = (u >= 0 - epsilon) & (u <= 1 + epsilon);
u = u(validU);
% v0 = v0(validU, :);
% v1 = v1(validU, :);
% v2 = v2(validU, :);
e1 = e1(validU, :);
e2 = e2(validU, :);
det = det(validU);
tVec = tVec(validU, :);
rayDir_M = rayDir_M(validU, :);
originalFaceIndices = originalFaceIndices(validU);

% 计算q向量 (q = tVec x e1)
q = cross(tVec, e1, 2); % [K2x3], K2=sum(validU)

% 计算v参数 (v = (rayDir ⋅ q) / det)
v = dot(rayDir_M, q, 2) ./ det; % [K2x1]

% 剔除v不在[0,1-u]区间的面元
validV = (v >= 0 - epsilon) & (u + v <= 1 + epsilon);
% v = v(validV);
% u = u(validV);
% v0 = v0(validV, :);
e2 = e2(validV, :);
det = det(validV);
q = q(validV, :);
originalFaceIndices = originalFaceIndices(validV);

% 计算t参数 (t = (e2 ⋅ q) / det)
t = dot(e2, q, 2) ./ det; % [K3x1], K3=sum(validV)

% 剔除t为负数的结果（射线反方向）
validT = t >= 0;
t = t(validT);
originalFaceIndices = originalFaceIndices(validT);

%% 计算交点

% 计算最终交点坐标
intersectPoints = rayOrigin + t .* rayDir; % [K4x3], K3=sum(validT)

% 返回原始面元索引
intersectFaces = originalFaceIndices;

% 交点去重(交点位于三角形顶点处或边上)
intersectPoints_approximate = round(intersectPoints, 13);  %%%%%%%%%%% 四舍五入为小数点后第13位小数 
intersectPoints_RemoveDuplicates = unique(intersectPoints_approximate, 'rows');  % 去重
[m,n] = size(intersectPoints_RemoveDuplicates);


%% 计算交点处法向量 

normals = normals(intersectFaces,:);


% 重复交点处理
if size(intersectFaces) == m    % 无重复交点
intersectNormals_RemoveDuplicates = normals;

else                            % 有重复交点
validPoint = cell(m,1);
intersectNormals = cell(m,1);
intersectNormals_RemoveDuplicates = zeros(m,3);

   for i=1:m
   validPoint{i} = find(all(intersectPoints_approximate == intersectPoints_RemoveDuplicates(i,:), 2));
   intersectNormals{i} = normals(validPoint{i},:);
   intersectNormals_RemoveDuplicates(i,:) = mean(intersectNormals{i}, 1); % 法向量 取平均
   end

end

% 处理无交点的情况
if isempty(intersectFaces)
    intersectPoints = [];
    intersectPoints_RemoveDuplicates = [];
    intersectNormals_RemoveDuplicates = [];
end




end

