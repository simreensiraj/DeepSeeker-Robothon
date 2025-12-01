%% Animate Submarine CAD Model
% Creates 3D animation of submarine following the survey path

fprintf('=== Creating Submarine Animation ===\n');

% Load results and configuration
load('seabed_survey_results.mat');
load('seabed_mapping_params.mat');

%% Create figure
fig = figure('Name', 'DeepSeeker Submarine Animation', ...
             'Position', [100, 100, 1200, 800], 'Color', 'w');

%% Plot terrain
surf(terrain.X, terrain.Y, terrain.Z, 'EdgeColor', 'none', ...
     'FaceAlpha', 0.6, 'FaceColor', [0.6 0.5 0.4]);
hold on;

% Plot path
plot3(results.optimal_path(:,1), results.optimal_path(:,2), results.optimal_path(:,3), ...
      'r--', 'LineWidth', 2, 'DisplayName', 'Planned Route');

colormap(parula);
xlabel('X Position (m)', 'FontSize', 12);
ylabel('Y Position (m)', 'FontSize', 12);
zlabel('Depth (m)', 'FontSize', 12);
title('DeepSeeker Autonomous Submarine - Seabed Survey', 'FontSize', 14, 'FontWeight', 'bold');
view(45, 25);
grid on;
axis equal;
lighting gouraud;
light('Position', [50, 50, 0]);
light('Position', [-50, -50, 10]);

%% Create simplified submarine model
% We'll create a simple submarine shape since CAD import requires Simscape
function [X, Y, Z] = create_submarine_model(length, diameter)
    % Main body (cylinder)
    [X_body, Y_body, Z_body] = cylinder(diameter/2, 20);
    Z_body = Z_body * length - length/2;
    
    % Front cone (nose)
    [X_nose, Y_nose, Z_nose] = cylinder([0, diameter/2], 20);
    Z_nose = Z_nose * (length/4) + length/2;
    
    % Rear cone (tail)
    [X_tail, Y_tail, Z_tail] = cylinder([diameter/2, diameter/4], 20);
    Z_tail = Z_tail * (length/5) - (length/2 + length/5);
    
    % Combine (use cell array to avoid dimension mismatch)
    X = [X_nose(1:end-1,:); X_body; X_tail(2:end,:)];
    Y = [Y_nose(1:end-1,:); Y_body; Y_tail(2:end,:)];
    Z = [Z_nose(1:end-1,:); Z_body; Z_tail(2:end,:)];
end

[sub_X, sub_Y, sub_Z] = create_submarine_model(sub.length, sub.diameter);

% Initial submarine position
sub_handle = surf(sub_X, sub_Y, sub_Z, ...
                  'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'none', ...
                  'FaceAlpha', 0.9);

% Add fins
fin_width = sub.diameter * 0.3;
fin_length = sub.length * 0.2;

% Vertical fin
[X_vfin, Y_vfin, Z_vfin] = create_fin(fin_length, fin_width);
Z_vfin = Z_vfin + sub.diameter/2;
vfin_handle = surf(X_vfin, Y_vfin, Z_vfin, ...
                   'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none', ...
                   'FaceAlpha', 0.9);

% Horizontal fins (left and right)
[X_hfin, Y_hfin, Z_hfin] = create_fin(fin_length, fin_width);
Y_hfin_left = Y_hfin - sub.diameter/2;
Y_hfin_right = Y_hfin + sub.diameter/2;
hfin_left = surf(X_hfin, Y_hfin_left, Z_hfin, ...
                 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none', ...
                 'FaceAlpha', 0.9);
hfin_right = surf(X_hfin, Y_hfin_right, Z_hfin, ...
                  'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none', ...
                  'FaceAlpha', 0.9);

% Add LiDAR sensor (small cylinder on top)
[X_lidar, Y_lidar, Z_lidar] = cylinder(0.02, 10);
Z_lidar = Z_lidar * 0.05 + sub.diameter/2;
lidar_handle = surf(X_lidar, Y_lidar, Z_lidar, ...
                    'FaceColor', [0.1 0.5 0.8], 'EdgeColor', 'none');

% Trail line
trail_handle = plot3(nan, nan, nan, 'b-', 'LineWidth', 1.5);

%% Animation parameters
fprintf('  Animating submarine...\n');

% Downsample for faster animation
skip = 50;  % Show every 50th frame
frames = 1:skip:length(results.position);

% Initialize trail
trail_x = [];
trail_y = [];
trail_z = [];

%% Create video writer (optional)
create_video = true;
if create_video
    video = VideoWriter('submarine_animation.avi');
    video.FrameRate = 10;
    open(video);
    fprintf('  Recording video...\n');
end

%% Animation loop
for i = 1:length(frames)
    idx = frames(i);
    
    % Current position and orientation
    pos = results.position(idx, :);
    yaw = results.orientation(idx, 3);
    
    % Rotation matrix (yaw only for simplicity)
    R = [cos(yaw), -sin(yaw), 0;
         sin(yaw),  cos(yaw), 0;
         0,         0,        1];
    
    % Transform submarine body
    for j = 1:size(sub_X, 1)
        for k = 1:size(sub_X, 2)
            point = R * [sub_X(j,k); sub_Y(j,k); sub_Z(j,k)];
            sub_X_rot(j,k) = point(1) + pos(1);
            sub_Y_rot(j,k) = point(2) + pos(2);
            sub_Z_rot(j,k) = point(3) + pos(3);
        end
    end
    
    % Update submarine
    set(sub_handle, 'XData', sub_X_rot, 'YData', sub_Y_rot, 'ZData', sub_Z_rot);
    
    % Transform and update fins
    for j = 1:size(X_vfin, 1)
        for k = 1:size(X_vfin, 2)
            % Vertical fin
            point_v = R * [X_vfin(j,k); Y_vfin(j,k); Z_vfin(j,k)];
            X_vfin_rot(j,k) = point_v(1) + pos(1);
            Y_vfin_rot(j,k) = point_v(2) + pos(2);
            Z_vfin_rot(j,k) = point_v(3) + pos(3);
            
            % Horizontal fins
            point_hl = R * [X_hfin(j,k); Y_hfin_left(j,k); Z_hfin(j,k)];
            X_hfin_left_rot(j,k) = point_hl(1) + pos(1);
            Y_hfin_left_rot(j,k) = point_hl(2) + pos(2);
            Z_hfin_left_rot(j,k) = point_hl(3) + pos(3);
            
            point_hr = R * [X_hfin(j,k); Y_hfin_right(j,k); Z_hfin(j,k)];
            X_hfin_right_rot(j,k) = point_hr(1) + pos(1);
            Y_hfin_right_rot(j,k) = point_hr(2) + pos(2);
            Z_hfin_right_rot(j,k) = point_hr(3) + pos(3);
            
            % LiDAR
            point_l = R * [X_lidar(j,k); Y_lidar(j,k); Z_lidar(j,k)];
            X_lidar_rot(j,k) = point_l(1) + pos(1);
            Y_lidar_rot(j,k) = point_l(2) + pos(2);
            Z_lidar_rot(j,k) = point_l(3) + pos(3);
        end
    end
    
    set(vfin_handle, 'XData', X_vfin_rot, 'YData', Y_vfin_rot, 'ZData', Z_vfin_rot);
    set(hfin_left, 'XData', X_hfin_left_rot, 'YData', Y_hfin_left_rot, 'ZData', Z_hfin_left_rot);
    set(hfin_right, 'XData', X_hfin_right_rot, 'YData', Y_hfin_right_rot, 'ZData', Z_hfin_right_rot);
    set(lidar_handle, 'XData', X_lidar_rot, 'YData', Y_lidar_rot, 'ZData', Z_lidar_rot);
    
    % Update trail
    trail_x = [trail_x, pos(1)];
    trail_y = [trail_y, pos(2)];
    trail_z = [trail_z, pos(3)];
    set(trail_handle, 'XData', trail_x, 'YData', trail_y, 'ZData', trail_z);
    
    % Update title with progress
    time_elapsed = results.time(idx);
    title(sprintf('DeepSeeker Seabed Survey - Time: %.1f s (%.1f%%)', ...
                  time_elapsed, idx/length(results.position)*100), ...
          'FontSize', 14, 'FontWeight', 'bold');
    
    % Update view (slowly rotate)
    view(45 + i*0.2, 25);
    
    drawnow;
    
    % Capture frame for video
    if create_video
        frame = getframe(fig);
        writeVideo(video, frame);
    end
    
    % Progress indicator
    if mod(i, round(length(frames)/10)) == 0
        fprintf('  Progress: %d%%\n', round(i/length(frames)*100));
    end
end

%% Close video
if create_video
    close(video);
    fprintf('✓ Video saved: submarine_animation.avi\n');
end

fprintf('\n✅ Animation complete!\n');
fprintf('  Frames rendered: %d\n', length(frames));
fprintf('  Animation figure is interactive - rotate with mouse!\n\n');

%% Helper function to create fins
function [X, Y, Z] = create_fin(length, width)
    % Create triangular fin
    X = [-length/2, 0, -length/2, -length/2;
         -length/2, 0, -length/2, -length/2];
    Y = [0, 0, 0, 0;
         0, 0, 0, 0];
    Z = [0, width, 0, 0;
         0, 0, 0, 0];
end
