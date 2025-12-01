%% A* Path Planning for Seabed Cable Route
% Finds optimal safe path for cable laying avoiding obstacles

function [path, cost_map] = compute_cable_route(terrain, pathplan)
    
    fprintf('=== Computing Optimal Cable Route ===\n');
    
    % Create grid for A* algorithm
    grid_size = size(terrain.Z);
    
    % Ensure indices are within bounds
    start_idx = [max(1, min(grid_size(1), round(pathplan.start(2)))), ...
                 max(1, min(grid_size(2), round(pathplan.start(1))))];
    goal_idx = [max(1, min(grid_size(1), round(pathplan.goal(2)))), ...
                max(1, min(grid_size(2), round(pathplan.goal(1))))];
    
    fprintf('  Start index: [%d, %d]\n', start_idx);
    fprintf('  Goal index: [%d, %d]\n', goal_idx);
    fprintf('  Grid size: [%d, %d]\n', grid_size);
    
    % Calculate slope map
    [Gx, Gy] = gradient(terrain.Z, 1.0);
    slope_map = atan(sqrt(Gx.^2 + Gy.^2)) * 180/pi;
    
    % Calculate roughness (local terrain variation)
    roughness_map = stdfilt(terrain.Z, ones(5,5));
    
    % Create cost map (lower is better for cable laying)
    cost_map = ones(grid_size);
    
    % Penalize steep slopes
    cost_map = cost_map + (slope_map / pathplan.max_slope).^2 * pathplan.weights.slope;
    
    % Penalize rough terrain
    cost_map = cost_map + (roughness_map / pathplan.roughness_threshold) * pathplan.weights.roughness;
    
    % Mark unsafe areas as very high cost
    cost_map(slope_map > pathplan.max_slope * 1.5) = 1000;
    
    % A* implementation
    fprintf('  Running A* algorithm...\n');
    
    open_set = start_idx;
    came_from = zeros(grid_size(1), grid_size(2), 2);
    g_score = inf(grid_size);
    g_score(start_idx(1), start_idx(2)) = 0;
    f_score = inf(grid_size);
    f_score(start_idx(1), start_idx(2)) = heuristic(start_idx, goal_idx);
    
    iterations = 0;
    max_iterations = 10000;
    
    while ~isempty(open_set) && iterations < max_iterations
        iterations = iterations + 1;
        
        % Find node with lowest f_score
        [~, min_idx] = min(f_score(sub2ind(grid_size, open_set(:,1), open_set(:,2))));
        current = open_set(min_idx, :);
        
        % Check if reached goal
        if norm(current - goal_idx) < 2
            path = reconstruct_path(came_from, current, terrain);
            fprintf('  ✓ Path found! Length: %.1f meters\n', size(path, 1));
            fprintf('  ✓ Iterations: %d\n', iterations);
            return;
        end
        
        % Remove current from open set
        open_set(min_idx, :) = [];
        
        % Check neighbors (8-connected)
        for dx = -1:1
            for dy = -1:1
                if dx == 0 && dy == 0
                    continue;
                end
                
                neighbor = current + [dx, dy];
                
                % Check bounds
                if neighbor(1) < 1 || neighbor(1) > grid_size(1) || ...
                   neighbor(2) < 1 || neighbor(2) > grid_size(2)
                    continue;
                end
                
                % Calculate tentative g_score
                move_cost = sqrt(dx^2 + dy^2) * cost_map(neighbor(1), neighbor(2));
                tentative_g = g_score(current(1), current(2)) + move_cost;
                
                if tentative_g < g_score(neighbor(1), neighbor(2))
                    % This path is better
                    came_from(neighbor(1), neighbor(2), :) = current;
                    g_score(neighbor(1), neighbor(2)) = tentative_g;
                    f_score(neighbor(1), neighbor(2)) = tentative_g + heuristic(neighbor, goal_idx);
                    
                    % Add to open set if not already there
                    if ~any(all(open_set == neighbor, 2))
                        open_set = [open_set; neighbor];
                    end
                end
            end
        end
    end
    
    % No path found - create straight line path
    fprintf('  ⚠ No path found. Using straight line.\n');
    num_points = 100;
    path = zeros(num_points, 3);
    path(:,1) = linspace(pathplan.start(1), pathplan.goal(1), num_points)';
    path(:,2) = linspace(pathplan.start(2), pathplan.goal(2), num_points)';
    
    % Interpolate depth from terrain
    for i = 1:num_points
        if path(i,1) >= min(terrain.X(:)) && path(i,1) <= max(terrain.X(:)) && ...
           path(i,2) >= min(terrain.Y(:)) && path(i,2) <= max(terrain.Y(:))
            path(i,3) = interp2(terrain.X, terrain.Y, terrain.Z, path(i,1), path(i,2), 'linear', pathplan.start(3));
        else
            path(i,3) = pathplan.start(3);
        end
    end
end

function h = heuristic(a, b)
    % Euclidean distance heuristic
    h = sqrt(sum((a - b).^2));
end

function path = reconstruct_path(came_from, current, terrain)
    % Reconstruct path from came_from map
    path = [current(2), current(1)];  % x, y
    
    max_iterations = 1000;
    iter = 0;
    
    while any(came_from(current(1), current(2), :)) && iter < max_iterations
        iter = iter + 1;
        current = squeeze(came_from(current(1), current(2), :))';
        if current(1) == 0 || current(2) == 0
            break;
        end
        path = [current(2), current(1); path];
    end
    
    % Add depth from terrain
    depth = zeros(size(path,1), 1);
    for i = 1:size(path,1)
        if path(i,1) >= min(terrain.X(:)) && path(i,1) <= max(terrain.X(:)) && ...
           path(i,2) >= min(terrain.Y(:)) && path(i,2) <= max(terrain.Y(:))
            depth(i) = interp2(terrain.X, terrain.Y, terrain.Z, path(i,1), path(i,2), 'linear', 0);
        end
    end
    path = [path, depth];
end
