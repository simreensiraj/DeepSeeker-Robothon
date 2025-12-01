%% Obstacle Avoidance for Seabed Navigation
% Real-time obstacle detection and avoidance using LiDAR data

function avoidance_vector = obstacle_avoidance(submarine_pos, submarine_vel, pointcloud, params)
    
    avoidance_vector = [0, 0, 0];
    
    if isempty(pointcloud)
        return;
    end
    
    % Extract position from pointcloud
    points = pointcloud(:, 1:3);
    
    % Find nearby obstacles
    distances = vecnorm(points - submarine_pos, 2, 2);
    nearby = distances < params.detection_range;
    
    if ~any(nearby)
        return;  % No obstacles detected
    end
    
    nearby_points = points(nearby, :);
    nearby_distances = distances(nearby);
    
    % For each nearby point, calculate repulsive force
    for i = 1:size(nearby_points, 1)
        if nearby_distances(i) < params.safe_distance
            % Calculate repulsion vector (away from obstacle)
            diff_vector = submarine_pos - nearby_points(i, :);
            diff_vector = diff_vector / norm(diff_vector);  % Normalize
            
            % Inverse square law for repulsion strength
            strength = params.avoidance_gain * (1 / nearby_distances(i)^2);
            
            avoidance_vector = avoidance_vector + strength * diff_vector;
        end
    end
    
    % Limit maximum avoidance force
    max_avoidance = 5.0;  % meters per second
    if norm(avoidance_vector) > max_avoidance
        avoidance_vector = avoidance_vector / norm(avoidance_vector) * max_avoidance;
    end
end
