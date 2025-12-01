%% Run Seabed Survey Simulation
% KUEC Robothon 2025 - Autonomous Seabed Mapping for Cable Laying

clc;
fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║        DEEPSEEKER SEABED SURVEY SIMULATION                    ║\n');
fprintf('║        Autonomous Cable Route Mapping                       ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');

%% Load Configuration
if ~exist('seabed_mapping_params.mat', 'file')
    error('Configuration not found! Run setup_seabed_mapping.m first.');
end

load('seabed_mapping_params.mat');
fprintf('✓ Configuration loaded\n\n');

%% Compute Optimal Cable Route
fprintf('=== Step 1: Path Planning ===\n');
[optimal_path, cost_map] = compute_cable_route(terrain, pathplan);

% Evaluate path quality
path_length = sum(sqrt(sum(diff(optimal_path).^2, 2)));
fprintf('  Path length: %.2f meters\n', path_length);

% Check slopes along path
path_slopes = [];
for i = 1:size(optimal_path,1)-1
    dz = optimal_path(i+1,3) - optimal_path(i,3);
    dh = norm(optimal_path(i+1,1:2) - optimal_path(i,1:2));
    path_slopes(i) = abs(atan(dz/dh)) * 180/pi;
end
fprintf('  Max slope: %.2f degrees\n', max(path_slopes));
fprintf('  Avg slope: %.2f degrees\n', mean(path_slopes));

if max(path_slopes) <= pathplan.max_slope
    fprintf('  ✅ Path meets safety criteria!\n\n');
else
    fprintf('  ⚠️  Path exceeds max slope in %d segments\n\n', sum(path_slopes > pathplan.max_slope));
end

%% Simulate Survey Mission
fprintf('=== Step 2: Survey Mission ===\n');

% Time vector
t = 0:sim.fixed_step:sim.duration;
num_steps = length(t);

% Preallocate arrays
position = zeros(num_steps, 3);
velocity = zeros(num_steps, 3);
orientation = zeros(num_steps, 3);  % [roll, pitch, yaw]
scan_data = cell(num_steps, 1);

% Initial conditions
position(1,:) = pathplan.start;
velocity(1,:) = [0, 0, 0];
orientation(1,:) = [0, 0, 0];

fprintf('  Simulating %.1f minute survey...\n', sim.duration/60);
fprintf('  Progress: ');

% Main simulation loop
for i = 2:num_steps
    % Progress indicator
    if mod(i, round(num_steps/20)) == 0
        fprintf('█');
    end
    
    % Determine target waypoint (follow optimal path)
    path_idx = max(1, min(round(i / num_steps * size(optimal_path,1)), size(optimal_path,1)));
    target = optimal_path(path_idx, :);
    
    % Simulate LiDAR scan (every 50 steps to save computation - was 10)
    if mod(i, 50) == 0
        scan_data{i} = simulate_lidar_scan(position(i-1,:), orientation(i-1,:), terrain, sensor);
        
        % Check for obstacles and compute avoidance
        if ~isempty(scan_data{i})
            avoid_vec = obstacle_avoidance(position(i-1,:), velocity(i-1,:), ...
                                          scan_data{i}, obstacle_avoid);
        else
            avoid_vec = [0, 0, 0];
        end
    else
        avoid_vec = [0, 0, 0];
    end
    
    % Simple controller: move towards target + avoidance
    desired_velocity = (target - position(i-1,:)) * 0.5 + avoid_vec;
    
    % Limit speed
    max_speed = 2.0;  % m/s
    speed = norm(desired_velocity);
    if speed > max_speed
        desired_velocity = desired_velocity / speed * max_speed;
    end
    
    % Update velocity (simple dynamics)
    velocity(i,:) = 0.8 * velocity(i-1,:) + 0.2 * desired_velocity;
    
    % Update position
    position(i,:) = position(i-1,:) + velocity(i,:) * sim.fixed_step;
    
    % Keep submarine at target depth
    position(i,3) = position(i,3) * 0.9 + target(3) * 0.1;
    
    % Update orientation (point towards velocity)
    if norm(velocity(i,1:2)) > 0.1
        orientation(i,3) = atan2(velocity(i,2), velocity(i,1));
    else
        orientation(i,3) = orientation(i-1,3);
    end
end

fprintf(' COMPLETE!\n\n');

%% Save Results
fprintf('=== Step 3: Saving Results ===\n');

results.time = t';
results.position = position;
results.velocity = velocity;
results.orientation = orientation;
results.optimal_path = optimal_path;
results.cost_map = cost_map;
results.scan_data = scan_data;
results.path_slopes = path_slopes;

save('seabed_survey_results.mat', 'results', '-v7.3');
fprintf('✓ Results saved to: seabed_survey_results.mat\n\n');

%% Generate Report
fprintf('=== Mission Summary ===\n');
fprintf('  Survey duration: %.1f minutes\n', sim.duration/60);
fprintf('  Distance traveled: %.2f meters\n', sum(vecnorm(diff(position), 2, 2)));
fprintf('  Average speed: %.2f m/s\n', mean(vecnorm(velocity, 2, 2)));
fprintf('  LiDAR scans: %d\n', sum(~cellfun(@isempty, scan_data)));
fprintf('  Path quality: ');
if max(path_slopes) <= pathplan.max_slope
    fprintf('✅ EXCELLENT (safe for cable laying)\n');
else
    fprintf('⚠️  CAUTION (manual inspection needed)\n');
end
fprintf('\n');

%% Visualize Results
fprintf('=== Step 4: Visualization ===\n');
visualize_survey_results;

fprintf('\n✅ Survey mission complete!\n');
fprintf('📊 Review the figures for detailed analysis\n\n');
