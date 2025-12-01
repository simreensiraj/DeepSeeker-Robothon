%% Underwater Cable Scanning Animation with LiDAR
% Creates cinematic underwater visualization of submarine scanning cables

function animate_underwater_scanning()
    
    fprintf('=== Creating Underwater Cable Scanning Animation ===\n');
    
    % Load survey results
    if ~exist('seabed_survey_results.mat', 'file')
        error('Please run run_seabed_survey first to generate simulation data!');
    end
    
    survey_data = load('seabed_survey_results.mat');
    position = survey_data.position;
    orientation = survey_data.orientation;
    time = survey_data.time;
    lidar_scans = survey_data.lidar_scans;
    lidar_times = survey_data.lidar_times;
    
    params = load('seabed_mapping_params.mat');
    terrain = params.terrain;
    pathplan = params.pathplan;
    
    % Submarine parameters
    sub.length = 0.6;
    sub.diameter = 0.15;
    
    % Create figure
    figure('Name', 'Underwater Cable Scanning', 'Position', [100, 100, 1400, 800], ...
           'Color', [0.05 0.15 0.25]);
    
    % Setup 3D axes
    ax = axes('Position', [0.05 0.05 0.9 0.9]);
    hold on;
    view(45, 25);
    grid on;
    
    % Create underwater lighting and atmosphere
    set(gca, 'Color', [0.05 0.15 0.25]);
    set(gca, 'XColor', [0.3 0.5 0.6], 'YColor', [0.3 0.5 0.6], 'ZColor', [0.3 0.5 0.6]);
    
    % Add underwater terrain (seabed)
    terrain_handle = surf(terrain.X, terrain.Y, terrain.Z, ...
                          'FaceColor', [0.4 0.3 0.2], ...
                          'EdgeColor', 'none', ...
                          'FaceAlpha', 0.6, ...
                          'AmbientStrength', 0.3);
    
    % Create simulated undersea cables on terrain
    num_cables = 3;
    cable_handles = [];
    
    for i = 1:num_cables
        % Random cable path across terrain
        cable_x = linspace(10, 90, 50) + randn(1, 50) * 5;
        cable_y = linspace(10 + i*25, 90 - i*15, 50) + randn(1, 50) * 5;
        cable_z = zeros(size(cable_x));
        
        % Interpolate depth from terrain
        for j = 1:length(cable_x)
            cable_z(j) = interp2(terrain.X, terrain.Y, terrain.Z, ...
                                cable_x(j), cable_y(j), 'linear', -50) + 0.1;
        end
        
        cable_handles(i) = plot3(cable_x, cable_y, cable_z, ...
                                 'Color', [0.8 0.3 0.1], ...
                                 'LineWidth', 3, ...
                                 'LineStyle', '-');
    end
    
    % Create submarine model
    [sub_X, sub_Y, sub_Z] = create_submarine_model(sub.length, sub.diameter);
    
    % Initial submarine
    sub_handle = surf(sub_X, sub_Y, sub_Z, ...
                      'FaceColor', [0.9 0.9 0.95], 'EdgeColor', 'none', ...
                      'FaceAlpha', 0.95, ...
                      'SpecularStrength', 0.8, 'DiffuseStrength', 0.6);
    
    % Add fins
    fin_width = sub.diameter * 0.3;
    fin_length = sub.length * 0.2;
    
    [fin_X, fin_Y, fin_Z] = create_fin(fin_length, fin_width);
    
    % Vertical fin (top)
    vfin_handle = surf(fin_X, fin_Y, fin_Z + sub.diameter/2, ...
                       'FaceColor', [0.7 0.7 0.8], 'EdgeColor', 'none', ...
                       'FaceAlpha', 0.9);
    
    % Horizontal fins (sides)
    hfin1_handle = surf(fin_X, fin_Z + sub.diameter/2, fin_Y, ...
                        'FaceColor', [0.7 0.7 0.8], 'EdgeColor', 'none', ...
                        'FaceAlpha', 0.9);
    hfin2_handle = surf(fin_X, fin_Z - sub.diameter/2, fin_Y, ...
                        'FaceColor', [0.7 0.7 0.8], 'EdgeColor', 'none', ...
                        'FaceAlpha', 0.9);
    
    % LiDAR sensor (blue glowing sphere on top)
    [lidar_X, lidar_Y, lidar_Z] = sphere(12);
    lidar_radius = 0.03;
    lidar_handle = surf(lidar_X*lidar_radius, lidar_Y*lidar_radius, ...
                        lidar_Z*lidar_radius + sub.diameter/2, ...
                        'FaceColor', [0.2 0.6 1], 'EdgeColor', 'none', ...
                        'FaceAlpha', 0.8, 'FaceLighting', 'gouraud');
    
    % LiDAR beam visualization (will update dynamically)
    lidar_beam_handles = [];
    num_beams = 16;
    
    for i = 1:num_beams
        lidar_beam_handles(i) = plot3([0 0], [0 0], [0 0], ...
                                      'Color', [0.3 0.8 1], ...
                                      'LineWidth', 1.5, ...
                                      'LineStyle', '-');
    end
    
    % Trail
    trail_x = [];
    trail_y = [];
    trail_z = [];
    trail_handle = plot3(trail_x, trail_y, trail_z, ...
                         'Color', [0.4 0.7 1], 'LineWidth', 2, ...
                         'LineStyle', '--');
    
    % Lighting
    camlight('headlight');
    lighting gouraud;
    material([0.4 0.6 0.5 10 0.8]);
    
    % Axis limits
    xlim([0 100]); ylim([0 100]); zlim([min(terrain.Z(:))-10, 0]);
    xlabel('X (m)', 'FontSize', 12, 'Color', [0.7 0.9 1]);
    ylabel('Y (m)', 'FontSize', 12, 'Color', [0.7 0.9 1]);
    zlabel('Depth (m)', 'FontSize', 12, 'Color', [0.7 0.9 1]);
    title('Underwater Cable Scanning - LiDAR Survey', 'FontSize', 16, ...
          'Color', [0.8 0.95 1], 'FontWeight', 'bold');
    
    % Setup video writer
    video_file = 'underwater_cable_scanning.avi';
    video = VideoWriter(video_file, 'Motion JPEG AVI');
    video.FrameRate = 15;
    open(video);
    
    % Animation parameters
    skip = 50;  % Use every 50th position for smooth animation
    positions_to_animate = position(1:skip:end, :);
    orientations_to_animate = orientation(1:skip:end, :);
    times_to_animate = time(1:skip:end);
    num_frames = size(positions_to_animate, 1);
    
    fprintf('  Animating %d frames...\n', num_frames);
    
    % Find nearest LiDAR scan indices
    lidar_scan_idx = 1;
    
    % Animation loop
    for i = 1:num_frames
        % Current submarine state
        pos = positions_to_animate(i, :);
        yaw = orientations_to_animate(i, 3);
        
        % Rotation matrix for yaw
        R = [cos(yaw), -sin(yaw), 0;
             sin(yaw),  cos(yaw), 0;
             0,         0,        1];
        
        % Transform submarine body
        [X_rot, Y_rot, Z_rot] = transform_surface(sub_X, sub_Y, sub_Z, R, pos);
        set(sub_handle, 'XData', X_rot, 'YData', Y_rot, 'ZData', Z_rot);
        
        % Transform fins
        [X_rot, Y_rot, Z_rot] = transform_surface(fin_X, fin_Y, fin_Z + sub.diameter/2, R, pos);
        set(vfin_handle, 'XData', X_rot, 'YData', Y_rot, 'ZData', Z_rot);
        
        [X_rot, Y_rot, Z_rot] = transform_surface(fin_X, fin_Z + sub.diameter/2, fin_Y, R, pos);
        set(hfin1_handle, 'XData', X_rot, 'YData', Y_rot, 'ZData', Z_rot);
        
        [X_rot, Y_rot, Z_rot] = transform_surface(fin_X, fin_Z - sub.diameter/2, fin_Y, R, pos);
        set(hfin2_handle, 'XData', X_rot, 'YData', Y_rot, 'ZData', Z_rot);
        
        % Transform LiDAR sensor
        [X_rot, Y_rot, Z_rot] = transform_surface(lidar_X*lidar_radius, ...
                                                   lidar_Y*lidar_radius, ...
                                                   lidar_Z*lidar_radius + sub.diameter/2, ...
                                                   R, pos);
        set(lidar_handle, 'XData', X_rot, 'YData', Y_rot, 'ZData', Z_rot);
        
        % Update LiDAR beams (show scanning)
        if lidar_scan_idx <= length(lidar_scans) && ...
           times_to_animate(i) >= lidar_times(lidar_scan_idx)
            
            % Get current LiDAR scan
            scan = lidar_scans{lidar_scan_idx};
            
            if ~isempty(scan)
                % Sample beams to visualize
                num_points = size(scan, 1);
                beam_indices = round(linspace(1, num_points, num_beams));
                
                for b = 1:num_beams
                    if beam_indices(b) <= num_points
                        beam_end = scan(beam_indices(b), :);
                        set(lidar_beam_handles(b), ...
                            'XData', [pos(1), beam_end(1)], ...
                            'YData', [pos(2), beam_end(2)], ...
                            'ZData', [pos(3), beam_end(3)]);
                    end
                end
            end
            
            lidar_scan_idx = lidar_scan_idx + 1;
        end
        
        % Update trail
        trail_x = [trail_x, pos(1)];
        trail_y = [trail_y, pos(2)];
        trail_z = [trail_z, pos(3)];
        set(trail_handle, 'XData', trail_x, 'YData', trail_y, 'ZData', trail_z);
        
        % Rotate view for cinematic effect
        view(45 + i*0.15, 25 + sin(i*0.05)*5);
        
        % Update title with progress
        title_str = sprintf('Underwater Cable Scanning - %.1f%% Complete (t=%.1fs)', ...
                           i/num_frames*100, times_to_animate(i));
        title(title_str, 'FontSize', 16, 'Color', [0.8 0.95 1], 'FontWeight', 'bold');
        
        % Capture frame
        drawnow;
        frame = getframe(gcf);
        writeVideo(video, frame);
        
        % Progress indicator
        if mod(i, round(num_frames/10)) == 0
            fprintf('  %.0f%% complete...\n', i/num_frames*100);
        end
    end
    
    % Close video
    close(video);
    
    fprintf('✓ Animation complete! Saved to: %s\n', video_file);
    fprintf('  Total frames: %d\n', num_frames);
    fprintf('  Duration: %.1f seconds\n', num_frames/video.FrameRate);
end

%% Helper Functions

function [X, Y, Z] = create_submarine_model(length, diameter)
    % Create submarine body with nose and tail
    
    % Main cylindrical body
    [X_body, Y_body, Z_body] = cylinder(diameter/2, 20);
    Z_body = Z_body * length - length/2;
    
    % Front cone (nose)
    [X_nose, Y_nose, Z_nose] = cylinder([0, diameter/2], 20);
    Z_nose = Z_nose * (length/4) + length/2;
    
    % Rear cone (tail)
    [X_tail, Y_tail, Z_tail] = cylinder([diameter/2, diameter/4], 20);
    Z_tail = Z_tail * (length/5) - (length/2 + length/5);
    
    % Combine (avoid dimension mismatch)
    X = [X_nose(1:end-1,:); X_body; X_tail(2:end,:)];
    Y = [Y_nose(1:end-1,:); Y_body; Y_tail(2:end,:)];
    Z = [Z_nose(1:end-1,:); Z_body; Z_tail(2:end,:)];
end

function [X, Y, Z] = create_fin(length, width)
    % Create triangular fin as a surface
    X = [0, length, length, 0; 
         0, length, length, 0];
    Y = [0, 0, 0, 0;
         0, 0, 0, 0];
    Z = [0, width/2, width/2, width;
         0, width/2, width/2, width];
end

function [X_rot, Y_rot, Z_rot] = transform_surface(X, Y, Z, R, pos)
    % Apply rotation and translation to surface
    [rows, cols] = size(X);
    X_rot = zeros(rows, cols);
    Y_rot = zeros(rows, cols);
    Z_rot = zeros(rows, cols);
    
    for i = 1:rows
        for j = 1:cols
            point = [X(i,j); Y(i,j); Z(i,j)];
            transformed = R * point + pos(:);
            X_rot(i,j) = transformed(1);
            Y_rot(i,j) = transformed(2);
            Z_rot(i,j) = transformed(3);
        end
    end
end
