%% DeepSeeker Seabed Mapping Simulation Setup
% KUEC Robothon 2025 - Track 1: Autonomous Navigation & Mapping
% Real-world application: Undersea cable route surveying

clc;
fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║   DEEPSEEKER SEABED MAPPING FOR CABLE ROUTE SURVEYING         ║\n');
fprintf('║   KUEC Robothon 2025 - Autonomous Navigation & Mapping      ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');

%% STEP 1: Submarine Physical Parameters
fprintf('=== STEP 1: Submarine Configuration ===\n');

sub.mass = 25;                      % kg
sub.length = 0.6;                   % m (60cm submarine)
sub.diameter = 0.15;                % m
sub.volume = pi * (sub.diameter/2)^2 * sub.length;  % m³
sub.buoyancy_force = sub.volume * 1025 * 9.81;      % N (seawater density)
sub.drag_coefficient = 0.82;        % Typical for submarine shape

fprintf('  Submarine mass: %.2f kg\n', sub.mass);
fprintf('  Length: %.2f m\n', sub.length);
fprintf('  Buoyancy force: %.2f N\n', sub.buoyancy_force);
fprintf('✓ Physical parameters configured\n\n');

%% STEP 2: Seabed Terrain Generation
fprintf('=== STEP 2: Generating Seabed Terrain ===\n');

% Terrain dimensions (100m x 100m survey area)
terrain.x_range = [0, 100];         % meters
terrain.y_range = [0, 100];         % meters
terrain.resolution = 1.0;           % 1m grid resolution
terrain.base_depth = -50;           % meters (50m below surface)

% Create terrain grid
[terrain.X, terrain.Y] = meshgrid(...
    terrain.x_range(1):terrain.resolution:terrain.x_range(2), ...
    terrain.y_range(1):terrain.resolution:terrain.y_range(2));

% Generate realistic seabed with features
terrain.Z = terrain.base_depth + ...
    3 * sin(terrain.X/10) .* cos(terrain.Y/10) + ...  % Gentle waves
    2 * randn(size(terrain.X)) + ...                   % Random roughness
    5 * exp(-((terrain.X-50).^2 + (terrain.Y-50).^2)/200);  % Central mound

% Add obstacles (rocks, trenches)
terrain.obstacles = [];
num_obstacles = 15;

for i = 1:num_obstacles
    obs.x = rand() * 90 + 5;
    obs.y = rand() * 90 + 5;
    obs.radius = rand() * 3 + 2;    % 2-5m radius
    obs.height = rand() * 4 + 2;    % 2-6m height
    obs.type = randi([1, 3]);       % 1=rock, 2=trench, 3=slope
    
    % Apply obstacle to terrain
    dist = sqrt((terrain.X - obs.x).^2 + (terrain.Y - obs.y).^2);
    mask = dist < obs.radius;
    
    if obs.type == 1  % Rock
        terrain.Z(mask) = terrain.Z(mask) + obs.height * (1 - dist(mask)/obs.radius);
    elseif obs.type == 2  % Trench
        terrain.Z(mask) = terrain.Z(mask) - obs.height * (1 - dist(mask)/obs.radius);
    else  % Steep slope
        terrain.Z(mask) = terrain.Z(mask) + obs.height * sin(dist(mask)/obs.radius * pi);
    end
    
    terrain.obstacles = [terrain.obstacles; obs];
end

fprintf('  Survey area: %d x %d meters\n', diff(terrain.x_range), diff(terrain.y_range));
fprintf('  Grid resolution: %.1f m\n', terrain.resolution);
fprintf('  Obstacles placed: %d\n', num_obstacles);
fprintf('✓ Seabed terrain generated\n\n');

%% STEP 3: Sensor Configuration (LiDAR + Sonar)
fprintf('=== STEP 3: Sensor Configuration ===\n');

sensor.lidar.channels = 32;         % 32-channel 3D LiDAR
sensor.lidar.range = 30;            % meters max range
sensor.lidar.fov_vertical = 40;     % degrees
sensor.lidar.fov_horizontal = 360;  % degrees
sensor.lidar.frequency = 10;        % Hz
sensor.lidar.noise = 0.02;          % meters

sensor.sonar.range = 50;            % meters
sensor.sonar.frequency = 5;         % Hz
sensor.sonar.noise = 0.1;           % meters

sensor.imu.frequency = 100;         % Hz
sensor.imu.noise_accel = 0.01;      % m/s²
sensor.imu.noise_gyro = 0.001;      % rad/s

sensor.depth.frequency = 50;        % Hz
sensor.depth.noise = 0.05;          % meters

fprintf('  LiDAR: %d channels, %dm range\n', sensor.lidar.channels, sensor.lidar.range);
fprintf('  Sonar: %dm range\n', sensor.sonar.range);
fprintf('  IMU: %d Hz\n', sensor.imu.frequency);
fprintf('✓ Sensor suite configured\n\n');

%% STEP 4: Path Planning Configuration
fprintf('=== STEP 4: Path Planning Setup ===\n');

pathplan.algorithm = 'A*';          % A* for optimal path
pathplan.start = [5, 5, -45];       % Start position
pathplan.goal = [95, 95, -45];      % End position

% Safety criteria for cable laying
pathplan.max_slope = 15;            % degrees (max acceptable slope)
pathplan.min_clearance = 3;         % meters (min obstacle clearance)
pathplan.roughness_threshold = 2;   % meters (max terrain variation)

% Cost function weights
pathplan.weights.distance = 1.0;
pathplan.weights.slope = 2.0;
pathplan.weights.roughness = 1.5;
pathplan.weights.depth_change = 1.0;

fprintf('  Algorithm: %s\n', pathplan.algorithm);
fprintf('  Start: [%.1f, %.1f, %.1f] m\n', pathplan.start);
fprintf('  Goal: [%.1f, %.1f, %.1f] m\n', pathplan.goal);
fprintf('  Max slope: %d°\n', pathplan.max_slope);
fprintf('✓ Path planning configured\n\n');

%% STEP 5: Control System (PID Controllers)
fprintf('=== STEP 5: Control System Tuning ===\n');

% Depth control PID
pid_depth.Kp = 50;
pid_depth.Ki = 5;
pid_depth.Kd = 10;

% Heading control PID
pid_heading.Kp = 30;
pid_heading.Ki = 2;
pid_heading.Kd = 8;

% Speed control PID
pid_speed.Kp = 20;
pid_speed.Ki = 1;
pid_speed.Kd = 5;

% Obstacle avoidance parameters
obstacle_avoid.detection_range = 10;  % meters
obstacle_avoid.safe_distance = 5;    % meters
obstacle_avoid.avoidance_gain = 2.0;

fprintf('  Depth PID: Kp=%.1f, Ki=%.1f, Kd=%.1f\n', pid_depth.Kp, pid_depth.Ki, pid_depth.Kd);
fprintf('  Heading PID: Kp=%.1f, Ki=%.1f, Kd=%.1f\n', pid_heading.Kp, pid_heading.Ki, pid_heading.Kd);
fprintf('  Obstacle detection: %.1fm range\n', obstacle_avoid.detection_range);
fprintf('✓ Control system configured\n\n');

%% STEP 6: Thrusters Configuration
fprintf('=== STEP 6: Thruster Configuration ===\n');

thruster.count = 4;                 % 2 horizontal + 2 vertical
thruster.max_force = 50;            % N per thruster
thruster.response_time = 0.1;       % seconds

% Thruster positions (relative to center of mass)
thruster.positions = [
    0.25,  0.05,  0;     % Forward starboard horizontal
    0.25, -0.05,  0;     % Forward port horizontal
   -0.25,  0,     0.05;  % Aft vertical up
   -0.25,  0,    -0.05   % Aft vertical down
];

fprintf('  Thrusters: %d total\n', thruster.count);
fprintf('  Max force per thruster: %.1f N\n', thruster.max_force);
fprintf('✓ Thruster system configured\n\n');

%% STEP 7: Simulation Parameters
fprintf('=== STEP 7: Simulation Configuration ===\n');

sim.duration = 600;                 % 600 seconds (10 minutes)
sim.fixed_step = 0.02;              % 50 Hz
sim.solver = 'ode4';                % Fixed-step Runge-Kutta

fprintf('  Duration: %.1f seconds\n', sim.duration);
fprintf('  Time step: %.3f s (%d Hz)\n', sim.fixed_step, 1/sim.fixed_step);
fprintf('✓ Simulation parameters set\n\n');

%% STEP 8: Save Configuration
fprintf('=== STEP 8: Saving Configuration ===\n');

save('seabed_mapping_params.mat', 'sub', 'terrain', 'sensor', ...
     'pathplan', 'pid_depth', 'pid_heading', 'pid_speed', ...
     'obstacle_avoid', 'thruster', 'sim');

fprintf('✓ Parameters saved to: seabed_mapping_params.mat\n\n');

%% STEP 9: Generate Initial Visualization
fprintf('=== STEP 9: Terrain Visualization ===\n');

figure('Name', 'Seabed Terrain - Cable Route Survey', 'Position', [100, 100, 1000, 700]);

% 3D terrain plot
subplot(2,2,1);
surf(terrain.X, terrain.Y, terrain.Z, 'EdgeColor', 'none');
hold on;
plot3(pathplan.start(1), pathplan.start(2), pathplan.start(3), ...
      'go', 'MarkerSize', 15, 'MarkerFaceColor', 'g', 'LineWidth', 2);
plot3(pathplan.goal(1), pathplan.goal(2), pathplan.goal(3), ...
      'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r', 'LineWidth', 2);
colormap(jet);
colorbar;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Depth (m)');
title('3D Seabed Terrain');
legend('Terrain', 'Start', 'Goal');
view(45, 30);
grid on;

% Slope map (critical for cable laying)
subplot(2,2,2);
[Gx, Gy] = gradient(terrain.Z, terrain.resolution);
slope = atan(sqrt(Gx.^2 + Gy.^2)) * 180/pi;
imagesc(terrain.x_range, terrain.y_range, slope);
hold on;
plot(pathplan.start(1), pathplan.start(2), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
plot(pathplan.goal(1), pathplan.goal(2), 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
colormap(gca, parula);
colorbar;
caxis([0, 30]);
xlabel('X (m)');
ylabel('Y (m)');
title('Slope Map (degrees)');
axis equal tight;

% Safety zones (green=safe, yellow=caution, red=unsafe)
subplot(2,2,3);
safety = zeros(size(slope));
safety(slope <= pathplan.max_slope) = 2;  % Safe
safety(slope > pathplan.max_slope & slope <= pathplan.max_slope*1.5) = 1;  % Caution
safety(slope > pathplan.max_slope*1.5) = 0;  % Unsafe

imagesc(terrain.x_range, terrain.y_range, safety);
hold on;
plot(pathplan.start(1), pathplan.start(2), 'wo', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
plot(pathplan.goal(1), pathplan.goal(2), 'wo', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
colormap(gca, [1 0 0; 1 1 0; 0 1 0]);  % Red, Yellow, Green
colorbar('Ticks', [0, 1, 2], 'TickLabels', {'Unsafe', 'Caution', 'Safe'});
xlabel('X (m)');
ylabel('Y (m)');
title('Cable Laying Safety Zones');
axis equal tight;

% Depth profile along straight line
subplot(2,2,4);
straight_line = [linspace(pathplan.start(1), pathplan.goal(1), 100)', ...
                 linspace(pathplan.start(2), pathplan.goal(2), 100)'];
depth_profile = interp2(terrain.X, terrain.Y, terrain.Z, ...
                        straight_line(:,1), straight_line(:,2));
distance = sqrt(sum(diff(straight_line).^2, 2));
cumulative_dist = [0; cumsum(distance)];

plot(cumulative_dist, depth_profile, 'b-', 'LineWidth', 2);
hold on;
yline(pathplan.start(3), 'g--', 'Target Depth');
grid on;
xlabel('Distance (m)');
ylabel('Depth (m)');
title('Depth Profile (Straight Line Path)');

fprintf('✓ Terrain visualization created\n\n');

%% Summary
fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║           SETUP COMPLETE - READY FOR SIMULATION             ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');

fprintf('📊 CONFIGURATION SUMMARY:\n');
fprintf('   • Survey area: %dx%d meters\n', diff(terrain.x_range), diff(terrain.y_range));
fprintf('   • Obstacles: %d features detected\n', num_obstacles);
fprintf('   • Safe zones: %.1f%% of area\n', sum(safety(:)==2)/numel(safety)*100);
fprintf('   • Simulation duration: %.1f minutes\n', sim.duration/60);
fprintf('\n');

fprintf('🎯 NEXT STEPS:\n');
fprintf('   1. Run: run_seabed_survey (to execute simulation)\n');
fprintf('   2. Path will be computed using %s algorithm\n', pathplan.algorithm);
fprintf('   3. LiDAR will scan terrain in real-time\n');
fprintf('   4. Results will show optimal cable route\n\n');

fprintf('📁 FILES CREATED:\n');
fprintf('   • seabed_mapping_params.mat\n');
fprintf('   • Terrain visualization figure\n\n');

fprintf('✅ Ready for KUEC Robothon 2025 demonstration!\n\n');
