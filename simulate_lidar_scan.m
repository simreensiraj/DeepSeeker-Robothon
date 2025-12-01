%% LiDAR Terrain Scanning Simulation
% Simulates 3D LiDAR point cloud generation for seabed mapping (optimized)

function pointcloud = simulate_lidar_scan(submarine_pos, submarine_orient, terrain, sensor)
    
    % LiDAR parameters (reduced for speed)
    channels = min(sensor.lidar.channels, 16);  % Reduce channels
    max_range = sensor.lidar.range;
    fov_v = sensor.lidar.fov_vertical * pi/180;
    fov_h = sensor.lidar.fov_horizontal * pi/180;
    
    % Generate scan angles (fewer points)
    v_angles = linspace(-fov_v/2, fov_v/2, channels);
    h_angles = linspace(-fov_h/2, fov_h/2, round(channels*1.5));  % Reduced from *2
    
    pointcloud = [];
    
    % For each LiDAR beam
    for v_ang = v_angles
        for h_ang = h_angles
            % Ray direction in submarine frame
            ray_dir = [cos(v_ang)*cos(h_ang); 
                       cos(v_ang)*sin(h_ang); 
                       sin(v_ang)];
            
            % Transform to world frame (simplified - assumes level submarine)
            yaw = submarine_orient(3);
            R = [cos(yaw), -sin(yaw), 0;
                 sin(yaw),  cos(yaw), 0;
                 0,         0,        1];
            ray_world = R * ray_dir;
            
            % Cast ray and find intersection with terrain (faster step size)
            for range = 1:2:max_range  % Step by 2m instead of 0.5m
                point = submarine_pos + range * ray_world';
                
                % Check if point hits terrain
                if point(1) >= min(terrain.X(:)) && point(1) <= max(terrain.X(:)) && ...
                   point(2) >= min(terrain.Y(:)) && point(2) <= max(terrain.Y(:))
                    
                    terrain_depth = interp2(terrain.X, terrain.Y, terrain.Z, ...
                                           point(1), point(2), 'linear', inf);
                    
                    if ~isnan(terrain_depth) && point(3) <= terrain_depth
                        % Hit detected - add noise
                        point = point + sensor.lidar.noise * randn(1,3);
                        pointcloud = [pointcloud; point];
                        break;
                    end
                end
            end
        end
    end
    
    % Add timestamp
    if ~isempty(pointcloud)
        pointcloud(:,4) = ones(size(pointcloud,1), 1) * now;
    end
end
