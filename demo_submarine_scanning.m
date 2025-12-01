%% Demo: Submarine Scanning Underwater Cables
% Standalone demonstration - no simulation data needed!

function demo_submarine_scanning()
    
    fprintf('=== Creating Submarine Scanning Demo ===\n');
    
    % Create demo environment
    [X, Y] = meshgrid(0:2:100, 0:2:100);
    Z = -50 + 5*sin(X/10) + 5*cos(Y/10) + randn(size(X))*0.5;
    
    % Submarine parameters
    sub_length = 0.6;
    sub_diameter = 0.15;
    
    % Create demo path (circle above terrain)
    t = linspace(0, 2*pi, 200);
    path_x = 50 + 25*cos(t);
    path_y = 50 + 25*sin(t);
    path_z = -20 + 5*sin(3*t);  % Undulating depth
    path_yaw = t + pi/2;  % Face forward along circle
    
    % Create figure with dark underwater look
    figure('Name', 'Submarine Cable Scanner', 'Position', [50, 50, 1600, 900], ...
           'Color', [0.02 0.1 0.15]);
    
    % Setup axes
    ax = axes('Position', [0.02 0.05 0.75 0.9]);
    hold on;
    view(45, 20);
    grid on;
    
    % Dark underwater atmosphere
    set(gca, 'Color', [0.02 0.1 0.15]);
    set(gca, 'XColor', [0.2 0.4 0.5], 'YColor', [0.2 0.4 0.5], 'ZColor', [0.2 0.4 0.5]);
    set(gca, 'GridColor', [0.1 0.3 0.4], 'GridAlpha', 0.3);
    
    % Seabed
    surf(X, Y, Z, 'FaceColor', [0.35 0.25 0.15], 'EdgeColor', 'none', ...
         'FaceAlpha', 0.8, 'AmbientStrength', 0.2);
    
    % Add undersea cables on seafloor
    cable_colors = [0.9 0.3 0.1; 0.8 0.5 0.1; 0.7 0.4 0.2];
    
    for c = 1:3
        cable_x = linspace(5, 95, 60) + randn(1, 60)*3;
        cable_y = 20 + c*20 + randn(1, 60)*4;
        cable_z = interp2(X, Y, Z, cable_x, cable_y) + 0.15;
        
        plot3(cable_x, cable_y, cable_z, 'Color', cable_colors(c,:), ...
              'LineWidth', 4, 'LineStyle', '-');
    end
    
    % Create submarine
    % Try to load STL file first, otherwise use procedural geometry
    use_stl = false;
    stl_file = 'Submarine.step';  % Check for STEP file
    
    if exist(stl_file, 'file')
        fprintf('  Found STL model: %s\n', stl_file);
        try
            TR = stlread(stl_file);
            use_stl = true;
            fprintf('  ✓ Loaded STL model successfully\n');
        catch
            fprintf('  ⚠ Could not read STL, using procedural geometry\n');
        end
    else
        fprintf('  Using procedural submarine geometry\n');
    end
    
    if use_stl
        % Use STL model
        % Scale and center the model
        vertices = TR.Points;
        scale_factor = sub_length / (max(vertices(:,1)) - min(vertices(:,1)));
        vertices = vertices * scale_factor;
        vertices = vertices - mean(vertices, 1);  % Center at origin
        
        sub_handle = trisurf(TR.ConnectivityList, vertices(:,1), vertices(:,2), vertices(:,3), ...
                             'FaceColor', [0.85 0.9 0.95], 'EdgeColor', 'none', ...
                             'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                             'SpecularStrength', 0.9, 'DiffuseStrength', 0.7, ...
                             'AmbientStrength', 0.5);
        
        % Store vertices for animation
        sub_vertices = vertices;
        sub_faces = TR.ConnectivityList;
    else
        % Use procedural geometry
        [sub_X, sub_Y, sub_Z] = create_submarine_geometry(sub_length, sub_diameter);
        
        sub_handle = surf(sub_X, sub_Y, sub_Z, ...
                          'FaceColor', [0.85 0.9 0.95], 'EdgeColor', 'none', ...
                          'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                          'SpecularStrength', 0.9, 'DiffuseStrength', 0.7, ...
                          'AmbientStrength', 0.5);
    end
    
    % Add glowing headlights (yellow spheres at front)
    [light_X, light_Y, light_Z] = sphere(10);
    light_scale = 0.025;
    
    light1 = surf(light_X*light_scale, light_Y*light_scale + sub_diameter*0.3, ...
                  light_Z*light_scale + sub_length*0.45, ...
                  'FaceColor', [1 0.9 0.3], 'EdgeColor', 'none', ...
                  'FaceAlpha', 0.9, 'FaceLighting', 'gouraud');
    
    light2 = surf(light_X*light_scale, light_Y*light_scale - sub_diameter*0.3, ...
                  light_Z*light_scale + sub_length*0.45, ...
                  'FaceColor', [1 0.9 0.3], 'EdgeColor', 'none', ...
                  'FaceAlpha', 0.9, 'FaceLighting', 'gouraud');
    
    % Add LiDAR sensor (blue sphere on top)
    lidar_scale = 0.035;
    lidar_sensor = surf(light_X*lidar_scale, light_Y*lidar_scale, ...
                        light_Z*lidar_scale + sub_diameter*0.6, ...
                        'FaceColor', [0.2 0.5 1], 'EdgeColor', 'none', ...
                        'FaceAlpha', 0.95, 'FaceLighting', 'gouraud', ...
                        'SpecularStrength', 1);
    
    % Add fins (only for procedural geometry)
    if ~use_stl
        [fin_X, fin_Y, fin_Z] = create_fin_geometry(sub_length*0.25, sub_diameter*0.4);
        vert_fin = surf(fin_X - sub_length*0.15, fin_Y, fin_Z + sub_diameter*0.5, ...
                        'FaceColor', [0.65 0.7 0.8], 'EdgeColor', 'none', ...
                        'FaceAlpha', 0.95, 'FaceLighting', 'gouraud');
        
        % Add horizontal fins (left/right)
        horiz_fin1 = surf(fin_X - sub_length*0.15, fin_Z + sub_diameter*0.5, fin_Y, ...
                          'FaceColor', [0.65 0.7 0.8], 'EdgeColor', 'none', ...
                          'FaceAlpha', 0.95, 'FaceLighting', 'gouraud');
        
        horiz_fin2 = surf(fin_X - sub_length*0.15, fin_Z - sub_diameter*0.5, fin_Y, ...
                          'FaceColor', [0.65 0.7 0.8], 'EdgeColor', 'none', ...
                          'FaceAlpha', 0.95, 'FaceLighting', 'gouraud');
    end
    
    % LiDAR scan beams (cyan lines)
    num_beams = 24;
    beam_handles = [];
    for b = 1:num_beams
        beam_handles(b) = plot3([0 0], [0 0], [0 0], ...
                                'Color', [0.2 0.8 1], 'LineWidth', 1.5, ...
                                'LineStyle', '-');
    end
    
    % Trail
    trail = plot3(path_x(1), path_y(1), path_z(1), ...
                  'Color', [0.3 0.7 1], 'LineWidth', 2.5, 'LineStyle', '--');
    
    % Lighting setup
    light('Position', [50 50 20], 'Style', 'local', 'Color', [0.4 0.5 0.6]);
    light('Position', [50 50 -100], 'Style', 'local', 'Color', [0.2 0.3 0.4]);
    lighting gouraud;
    material([0.5 0.7 0.6 20 0.9]);
    
    % Labels
    xlim([0 100]); ylim([0 100]); zlim([min(Z(:))-5, 0]);
    xlabel('X (m)', 'FontSize', 13, 'Color', [0.6 0.8 0.9], 'FontWeight', 'bold');
    ylabel('Y (m)', 'FontSize', 13, 'Color', [0.6 0.8 0.9], 'FontWeight', 'bold');
    zlabel('Depth (m)', 'FontSize', 13, 'Color', [0.6 0.8 0.9], 'FontWeight', 'bold');
    
    % Info panel on the right
    info_ax = axes('Position', [0.79 0.05 0.19 0.9], 'Visible', 'off');
    
    text(0.05, 0.95, '\bf\fontsize{16}UNDERWATER CABLE SURVEY', ...
         'Color', [0.7 0.9 1], 'Units', 'normalized', 'Interpreter', 'tex');
    
    text(0.05, 0.85, '\fontsize{12}\bfMission Status:', ...
         'Color', [0.8 0.9 1], 'Units', 'normalized', 'Interpreter', 'tex');
    
    status_text = text(0.05, 0.78, '', 'Color', [0.6 0.85 0.95], ...
                       'FontSize', 11, 'Units', 'normalized', 'Interpreter', 'none');
    
    text(0.05, 0.65, '\fontsize{12}\bfSensors:', ...
         'Color', [0.8 0.9 1], 'Units', 'normalized', 'Interpreter', 'tex');
    
    text(0.05, 0.58, sprintf('  • LiDAR: Active\n  • Sonar: Active\n  • IMU: Nominal\n  • Depth: %.1fm', ...
                             abs(path_z(1))), ...
         'Color', [0.5 0.8 0.95], 'FontSize', 10, 'Units', 'normalized', 'Interpreter', 'none');
    
    text(0.05, 0.38, '\fontsize{12}\bfObjectives:', ...
         'Color', [0.8 0.9 1], 'Units', 'normalized', 'Interpreter', 'tex');
    
    text(0.05, 0.31, sprintf('  ✓ Map seabed terrain\n  ✓ Detect cables\n  ✓ Avoid obstacles\n  ○ Survey complete'), ...
         'Color', [0.5 0.8 0.95], 'FontSize', 10, 'Units', 'normalized', 'Interpreter', 'none');
    
    % Animation loop
    fprintf('  Animating %d frames...\n', length(path_x));
    
    for i = 1:length(path_x)
        % Current position
        pos = [path_x(i), path_y(i), path_z(i)];
        yaw = path_yaw(i);
        
        % Rotation matrix
        R = [cos(yaw), -sin(yaw), 0;
             sin(yaw),  cos(yaw), 0;
             0,         0,        1];
        
        % Transform submarine
        if use_stl
            % Transform STL vertices
            vertices_rot = (R * sub_vertices')' + repmat(pos, size(sub_vertices, 1), 1);
            set(sub_handle, 'Vertices', vertices_rot);
        else
            % Transform procedural geometry
            [X_new, Y_new, Z_new] = transform_mesh(sub_X, sub_Y, sub_Z, R, pos);
            set(sub_handle, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        end
        
        % Transform fins (only for procedural geometry)
        if ~use_stl
            [X_new, Y_new, Z_new] = transform_mesh(fin_X - sub_length*0.15, fin_Y, ...
                                                    fin_Z + sub_diameter*0.5, R, pos);
            set(vert_fin, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
            
            [X_new, Y_new, Z_new] = transform_mesh(fin_X - sub_length*0.15, ...
                                                    fin_Z + sub_diameter*0.5, fin_Y, R, pos);
            set(horiz_fin1, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
            
            [X_new, Y_new, Z_new] = transform_mesh(fin_X - sub_length*0.15, ...
                                                    fin_Z - sub_diameter*0.5, fin_Y, R, pos);
            set(horiz_fin2, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        end
        
        % Transform lights
        [X_new, Y_new, Z_new] = transform_mesh(light_X*light_scale, ...
                                                light_Y*light_scale + sub_diameter*0.3, ...
                                                light_Z*light_scale + sub_length*0.45, R, pos);
        set(light1, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        [X_new, Y_new, Z_new] = transform_mesh(light_X*light_scale, ...
                                                light_Y*light_scale - sub_diameter*0.3, ...
                                                light_Z*light_scale + sub_length*0.45, R, pos);
        set(light2, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Transform LiDAR sensor
        [X_new, Y_new, Z_new] = transform_mesh(light_X*lidar_scale, light_Y*lidar_scale, ...
                                                light_Z*lidar_scale + sub_diameter*0.6, R, pos);
        set(lidar_sensor, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Update LiDAR beams (shoot down to seabed)
        for b = 1:num_beams
            angle = (b-1) * 2*pi / num_beams;
            beam_dir = R * [cos(angle)*0.5; sin(angle)*0.5; -1] * 15;
            beam_end = pos + beam_dir';
            
            % Clamp to terrain
            if beam_end(1) >= 0 && beam_end(1) <= 100 && ...
               beam_end(2) >= 0 && beam_end(2) <= 100
                beam_end(3) = interp2(X, Y, Z, beam_end(1), beam_end(2));
            end
            
            set(beam_handles(b), 'XData', [pos(1), beam_end(1)], ...
                                 'YData', [pos(2), beam_end(2)], ...
                                 'ZData', [pos(3), beam_end(3)]);
        end
        
        % Update trail
        set(trail, 'XData', path_x(1:i), 'YData', path_y(1:i), 'ZData', path_z(1:i));
        
        % Update status
        progress = i / length(path_x) * 100;
        set(status_text, 'String', sprintf('  Progress: %.0f%%\n  Position: [%.1f, %.1f]\n  Depth: %.1fm\n  Heading: %.0f°', ...
                                           progress, pos(1), pos(2), abs(pos(3)), mod(yaw*180/pi, 360)));
        
        % Slowly rotate view
        view(45 + i*0.2, 20 + sin(i*0.03)*8);
        
        % Update title
        axes(ax);
        title(sprintf('\\bfAutonomous Submarine - Cable Detection Mission - %.0f%% Complete', progress), ...
              'FontSize', 16, 'Color', [0.7 0.95 1], 'Interpreter', 'tex');
        
        drawnow;
        
        if mod(i, 20) == 0
            fprintf('  %.0f%%...\n', progress);
        end
        
        pause(0.03);  % Smooth animation
    end
    
    fprintf('✓ Demo complete!\n');
end

%% Helper Functions

function [X, Y, Z] = create_submarine_geometry(length, diameter)
    % Submarine body - use consistent segments
    nseg = 24;
    
    [X_body, Y_body, Z_body] = cylinder(diameter/2, nseg);
    Z_body = Z_body * length - length/2;
    
    % Nose cone
    [X_nose, Y_nose, Z_nose] = cylinder([0, diameter/2], nseg);
    Z_nose = Z_nose * (length/4) + length/2;
    
    % Tail cone
    [X_tail, Y_tail, Z_tail] = cylinder([diameter/2, diameter/5], nseg);
    Z_tail = Z_tail * (length/4) - (length/2 + length/4);
    
    % Combine - now all have same number of rows
    X = [X_nose(1:end-1,:); X_body; X_tail(2:end,:)];
    Y = [Y_nose(1:end-1,:); Y_body; Y_tail(2:end,:)];
    Z = [Z_nose(1:end-1,:); Z_body; Z_tail(2:end,:)];
end

function [X, Y, Z] = create_fin_geometry(length, width)
    % Triangular fin surface
    X = [0, 0; length, length];
    Y = [0, 0; 0, 0];
    Z = [0, width; width/2, width/2];
end

function [X_new, Y_new, Z_new] = transform_mesh(X, Y, Z, R, pos)
    [rows, cols] = size(X);
    X_new = zeros(rows, cols);
    Y_new = zeros(rows, cols);
    Z_new = zeros(rows, cols);
    
    for i = 1:rows
        for j = 1:cols
            point = R * [X(i,j); Y(i,j); Z(i,j)] + pos(:);
            X_new(i,j) = point(1);
            Y_new(i,j) = point(2);
            Z_new(i,j) = point(3);
        end
    end
end
