function [TR, face_normals, obj] = load_obj_with_normals(filename)
% 读取.obj格式文件
% 输出：
%      TR                         MATLAB triangulation 对象
%         TR.Points               顶点坐标       [N×3]
%         TR.ConnectivityList     三角形连接关系 [T×3]
%      face_normals               面法向量矩阵   [T×3]
%      obj                        结构体 包含完整obj解析数据
%         obj.xyz                 顶点坐标       [3xN]     
%         obj.face_order          每面的顶点数   [1xM]   每个元素表示一个面的顶点数量（如三角形为3，四边形为4）
%         obj.tri                 面的顶点索引   [PxM]
%         obj.normal              显示法向量     [3xK]   直接从OBJ文件的 vn语句解析得到（显式定义的法向量）
%         obj.vertex_normal       面的顶点法向量索引    [PxM]  存储每个面的顶点对应的法向量索引（指向normal中的列）
%         obj.vertex_mean_normal  顶点平均法向量  [3xN] 每个顶点的平均法向量（通过对共享该顶点的所有面的法向量加权平均计算，并归一化）
%         obj.node_num            顶点数量 N (数量统计)
%         obj.face_num            面数量 M (数量统计)
%         obj.normal_num          法向量数量 K (数量统计)
%         obj.order_max           单面最大顶点数 P



    % 第一次遍历：统计顶点、法向量和面的数量
    [vertex_count, normal_count, face_count, max_face_order] = count_obj_elements(filename);
    
    % 预分配内存
    vertices = zeros(vertex_count, 3);      % 顶点坐标 [Nx3]
    normals = zeros(normal_count, 3);       % 法向量 [Kx3]
    faces = cell(face_count, 1);            % 面的顶点索引
    face_normals_idx = cell(face_count, 1); % 面的法向量索引
    face_orders = zeros(1, face_count);     % 每面的顶点数 [1xM]
    
    % 初始化索引计数器
    v_idx = 1;
    vn_idx = 1;
    f_idx = 1;
    
    % 打开文件进行第二次遍历（实际读取）
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件: %s', filename);
    end
    
    % 解析OBJ文件
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || line(1) == '#' 
            continue; 
        end
        
        % 移除行尾空白
        line = strtrim(line);
        
        % 解析顶点
        if startsWith(line, 'v ')
            tokens = sscanf(line(3:end), '%f');
            if numel(tokens) >= 3
                vertices(v_idx, :) = tokens(1:3)';
                v_idx = v_idx + 1;
            end
            
        % 解析法向量
        elseif startsWith(line, 'vn ')
            tokens = sscanf(line(4:end), '%f');
            if numel(tokens) >= 3
                normals(vn_idx, :) = tokens(1:3)';
                vn_idx = vn_idx + 1;
            end
            
        % 解析面
        elseif startsWith(line, 'f ')
            tokens = split(line(3:end));
            face_verts = zeros(1, numel(tokens));
            face_norms = zeros(1, numel(tokens));
            valid_count = 0;
            
            for i = 1:numel(tokens)
                if isempty(tokens{i}), continue; end
                
                % 解析顶点/法向量索引
                parts = split(tokens{i}, '/');
                
                % 提取顶点索引
                if numel(parts) >= 1 && ~isempty(parts{1})
                    vert_idx = str2double(parts{1});
                    if vert_idx < 0
                        vert_idx = vertex_count + vert_idx + 1;
                    end
                    valid_count = valid_count + 1;
                    face_verts(valid_count) = vert_idx;
                end
                
                % 提取法向量索引
                if numel(parts) >= 3 && ~isempty(parts{3})
                    norm_idx = str2double(parts{3});
                    if norm_idx < 0
                        norm_idx = normal_count + norm_idx + 1;
                    end
                    face_norms(valid_count) = norm_idx;
                end
            end
            
            % 保存面数据
            if valid_count >= 3
                faces{f_idx} = face_verts(1:valid_count);
                face_orders(f_idx) = valid_count;
                
                % 保存法向量索引
                if any(face_norms(1:valid_count))
                    face_normals_idx{f_idx} = face_norms(1:valid_count);
                else
                    face_normals_idx{f_idx} = [];
                end
                
                f_idx = f_idx + 1;
            end
        end
    end
    fclose(fid);
    
    % 三角化处理
    triangles = [];
    for i = 1:face_count
        face = faces{i};
        nv = face_orders(i);
        
        % 多边形三角化 (扇形三角剖分)
        if nv >= 3
            for j = 2:(nv-1)
                triangles(end+1, :) = [face(1), face(j), face(j+1)]; %#ok<AGROW>
            end
        end
    end
    
    % 创建triangulation对象
    TR = triangulation(triangles, vertices);
    
    % 计算每个三角面片的法向量
    face_normals = faceNormal(TR);
    
    % 计算顶点平均法向量
    vertex_mean_normal = compute_vertex_normals(TR, face_normals);
    
    % 填充obj结构体
    obj = struct();
    obj.xyz = vertices';                    % 顶点坐标 [3xN]
    obj.face_order = face_orders;           % 每面的顶点数 [1xM]
    
    % 面的顶点索引 [PxM]
    obj.tri = zeros(max_face_order, face_count);
    for i = 1:face_count
        obj.tri(1:face_orders(i), i) = faces{i};
    end
    
    obj.normal = normals';                  % 法向量 [3xK]
    
    % 面的顶点法向量索引 [PxM]
    obj.vertex_normal = zeros(max_face_order, face_count);
    for i = 1:face_count
        if ~isempty(face_normals_idx{i})
            idxs = face_normals_idx{i};
            obj.vertex_normal(1:numel(idxs), i) = idxs;
        end
    end
    
    % 顶点平均法向量 [3xN]
    obj.vertex_mean_normal = vertex_mean_normal';
    
    % 统计信息
    obj.node_num = vertex_count;            % 顶点数量
    obj.face_num = face_count;              % 面数量
    obj.normal_num = normal_count;          % 法向量数量
    obj.order_max = max_face_order;         % 单面最大顶点数
end


%% 辅助函数：统计OBJ文件中的元素数量
function [vertex_count, normal_count, face_count, max_face_order] = count_obj_elements(filename)
    vertex_count = 0;
    normal_count = 0;
    face_count = 0;
    max_face_order = 0;
    
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件: %s', filename);
    end
    
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line), continue; end
        
        if startsWith(line, 'v ')
            vertex_count = vertex_count + 1;
        elseif startsWith(line, 'vn ')
            normal_count = normal_count + 1;
        elseif startsWith(line, 'f ')
            tokens = split(line(3:end));
            valid_count = 0;
            for i = 1:numel(tokens)
                if ~isempty(tokens{i}) && ~startsWith(tokens{i}, '#')
                    valid_count = valid_count + 1;
                end
            end
            if valid_count >= 3
                face_count = face_count + 1;
                if valid_count > max_face_order
                    max_face_order = valid_count;
                end
            end
        end
    end
    fclose(fid);
end


%% 计算顶点平均法向量
function vertex_normals = compute_vertex_normals(TR, face_normals)
    points = TR.Points;
    triangles = TR.ConnectivityList;
    vertex_normals = zeros(size(points, 1), 3);
    vertex_weights = zeros(size(points, 1), 1);
    
    % 遍历所有三角面片
    for i = 1:size(triangles, 1)
        tri = triangles(i, :);
        normal = face_normals(i, :);
        
        % 计算三角形面积作为权重
        v1 = points(tri(1), :);
        v2 = points(tri(2), :);
        v3 = points(tri(3), :);
        area = 0.5 * norm(cross(v2 - v1, v3 - v1));
        
        % 对每个顶点的法向量贡献加权累加
        for j = 1:3
            vidx = tri(j);
            vertex_normals(vidx, :) = vertex_normals(vidx, :) + normal * area;
            vertex_weights(vidx) = vertex_weights(vidx) + area;
        end
    end
    
    % 归一化顶点法向量
    for i = 1:size(vertex_normals, 1)
        if vertex_weights(i) > eps
            vertex_normals(i, :) = vertex_normals(i, :) / vertex_weights(i);
            norm_val = norm(vertex_normals(i, :));
            if norm_val > eps
                vertex_normals(i, :) = vertex_normals(i, :) / norm_val;
            end
        end
    end
end
