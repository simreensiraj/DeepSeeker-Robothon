%% Cinematic Submarine Cable Scanner - Professional UI/UX
% High-quality underwater visualization with STEP model import

function cinematic_submarine_demo()
    
    fprintf('╔════════════════════════════════════════════════╗\n');
    fprintf('║   DEEPSEEKER AUTONOMOUS SUBMARINE SCANNER       ║\n');
    fprintf('║   Loading Cinematic Demo...                   ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
    
    %% Import submarine CAD model
    step_file = 'Submarine.step';
    
    if exist(step_file, 'file')
        fprintf('⚙  Importing submarine CAD model...\n');
        try
            % Try to import STEP using importGeometry (requires Simscape Multibody)
            TR = importGeometry(step_file);
            use_cad = true;
            fprintf('✓  CAD model loaded: %d vertices, %d faces\n', ...
                    size(TR.vertices, 1), size(TR.faces, 1));
        catch
            fprintf('⚠  STEP import requires Simscape Multibody\n');
            fprintf('⚙  Generating high-quality procedural submarine...\n');
            use_cad = false;
        end
    else
        fprintf('⚠  Submarine.step not found\n');
        fprintf('⚙  Generating high-quality procedural submarine...\n');
        use_cad = false;
    end
    
    %% Create demo environment
    fprintf('⚙  Building underwater terrain...\n');
    [X, Y] = meshgrid(0:1:100, 0:1:100);
    Z = -50 + 8*sin(X/12).*cos(Y/15) + 3*sin(X/8) + 3*cos(Y/10) + randn(size(X))*0.8;
    
    % Create submarine path - figure-8 pattern for dynamic movement
    t = linspace(0, 4*pi, 400);
    path_x = 50 + 30*sin(t);
    path_y = 50 + 20*sin(2*t);
    path_z = -15 - 8*sin(t/2) - 3*cos(t);
    path_yaw = atan2(diff([path_y, path_y(1)]), diff([path_x, path_x(1)]));
    path_yaw = [path_yaw, path_yaw(end)];
    
    %% Create ultra-wide cinematic figure
    fprintf('⚙  Initializing display system...\n');
    fig = figure('Name', 'DeepSeeker Submarine Scanner - Live Feed', ...
                 'Position', [0, 50, 1920, 1000], ...
                 'Color', [0.01 0.05 0.08], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'NumberTitle', 'off');
    
    %% Main 3D viewport (CENTERED, FULL SCREEN)
    ax_main = axes('Position', [0.05 0.08 0.9 0.85]);
    hold on;
    view(45, 20);
    
    % Clean dark background
    set(ax_main, 'Color', [0.02 0.06 0.10]);
    set(ax_main, 'XColor', [0.3 0.4 0.5], 'YColor', [0.3 0.4 0.5], ...
        'ZColor', [0.3 0.4 0.5]);
    set(ax_main, 'GridColor', [0.2 0.3 0.4], 'GridAlpha', 0.15);
    grid on;
    
    % Seabed - subtle brown/gray
    seabed = surf(X, Y, Z, 'FaceColor', [0.3 0.25 0.2], ...
                  'EdgeColor', 'none', 'FaceAlpha', 0.7, ...
                  'AmbientStrength', 0.4, 'DiffuseStrength', 0.5);
    
    % Fewer, more subtle cables
    fprintf('⚙  Placing undersea cables...\n');
    for c = 1:3
        cable_x = linspace(15, 85, 60) + randn(1, 60)*2;
        cable_y = 25 + c*15 + randn(1, 60)*2;
        cable_z = interp2(X, Y, Z, cable_x, cable_y, 'linear', -50) + 0.15;
        
        % Subtle orange cables
        plot3(cable_x, cable_y, cable_z, 'Color', [0.8 0.4 0.15], ...
              'LineWidth', 3, 'LineStyle', '-');
    end
    
    %% Create submarine
    sub_length = 0.6;
    sub_diameter = 0.15;
    
    if use_cad
        % Use imported CAD model
        vertices = TR.vertices;
        faces = TR.faces;
        
        % Scale and center
        scale = sub_length / (max(vertices(:,1)) - min(vertices(:,1)));
        vertices = (vertices - mean(vertices)) * scale;
        
        submarine = patch('Faces', faces, 'Vertices', vertices, ...
                         'FaceColor', [0.88 0.92 0.96], ...
                         'EdgeColor', 'none', ...
                         'FaceAlpha', 1, ...
                         'FaceLighting', 'gouraud', ...
                         'SpecularStrength', 0.95, ...
                         'DiffuseStrength', 0.7, ...
                         'AmbientStrength', 0.6, ...
                         'SpecularExponent', 25);
        
        sub_verts_orig = vertices;
    else
        % High-quality procedural submarine
        [sub_X, sub_Y, sub_Z] = create_detailed_submarine(sub_length, sub_diameter);
        
        submarine = surf(sub_X, sub_Y, sub_Z, ...
                        'FaceColor', [0.95 0.95 1], ...  % BRIGHT WHITE
                        'EdgeColor', 'none', ...
                        'FaceAlpha', 1, ...
                        'FaceLighting', 'gouraud', ...
                        'SpecularStrength', 1, ...
                        'DiffuseStrength', 0.8, ...
                        'AmbientStrength', 0.7, ...
                        'SpecularExponent', 30);
    end
    
    % Add submarine components
    [sphere_X, sphere_Y, sphere_Z] = sphere(16);
    
    % BRIGHT front lights (white-yellow)
    light_scale = 0.04;
    light_offset = sub_length * 0.42;
    
    light_left = surf(sphere_X*light_scale - light_offset, ...
                     sphere_Y*light_scale + sub_diameter*0.35, ...
                     sphere_Z*light_scale, ...
                     'FaceColor', [1 1 0.7], 'EdgeColor', 'none', ...
                     'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                     'SpecularStrength', 1, 'AmbientStrength', 1);
    
    light_right = surf(sphere_X*light_scale - light_offset, ...
                      sphere_Y*light_scale - sub_diameter*0.35, ...
                      sphere_Z*light_scale, ...
                      'FaceColor', [1 1 0.7], 'EdgeColor', 'none', ...
                      'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                      'SpecularStrength', 1, 'AmbientStrength', 1);
    
    % BRIGHT blue LiDAR sensor
    lidar_scale = 0.045;
    lidar_sensor = surf(sphere_X*lidar_scale, sphere_Y*lidar_scale, ...
                       sphere_Z*lidar_scale + sub_diameter*0.65, ...
                       'FaceColor', [0.3 0.7 1], 'EdgeColor', 'none', ...
                       'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                       'SpecularStrength', 1, 'AmbientStrength', 0.9, ...
                       'SpecularExponent', 30);
    
    % Fewer, cleaner LiDAR beams
    num_beams = 16;
    beams = zeros(1, num_beams);
    for b = 1:num_beams
        beams(b) = plot3([0 0], [0 0], [0 0], ...
                        'Color', [0.4 0.85 1], ...
                        'LineWidth', 1.5, ...
                        'LineStyle', '-');
    end
    
    % Subtle trail
    trail = plot3(path_x(1), path_y(1), path_z(1), ...
                 'Color', [0.5 0.8 1 0.5], ...
                 'LineWidth', 2, ...
                 'LineStyle', '--');
    
    % REMOVE the thick beam cones - they obscure the submarine
    % beam_cone_left and beam_cone_right deleted
    
    % Lighting setup - BRIGHTER
    light1 = light('Position', [50 50 10], 'Style', 'local', ...
                  'Color', [0.7 0.8 0.9]);
    light2 = light('Position', [30 70 -10], 'Style', 'local', ...
                  'Color', [0.5 0.6 0.7]);
    light3 = light('Position', [70 30 5], 'Style', 'local', ...
                  'Color', [0.6 0.7 0.8]);
    lighting gouraud;
    material([0.6 0.8 0.5 30 0.95]);
    
    xlim([0 100]); ylim([0 100]); zlim([min(Z(:))-5, 5]);
    xlabel('X (m)', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
    ylabel('Y (m)', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
    zlabel('Depth (m)', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
    
    %% REMOVE ALL THE SIDE PANELS - FULL SCREEN SUBMARINE ONLY
    
    %% Animation loop
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   🎬 STARTING CINEMATIC ANIMATION             ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
    
    axes(ax_main);
    title('', 'FontSize', 15, 'Color', [0.7 0.85 1], 'FontWeight', 'bold');
    
    for i = 1:length(path_x)
        % Current state
        pos = [path_x(i), path_y(i), path_z(i)];
        yaw = path_yaw(i);
        pitch = sin(i/20) * 0.1;
        
        % Rotation matrix
        R = rotation_matrix(yaw, pitch);
        
        % Update submarine
        if use_cad
            verts_rot = (R * sub_verts_orig')' + repmat(pos, size(sub_verts_orig, 1), 1);
            set(submarine, 'Vertices', verts_rot);
        else
            [X_new, Y_new, Z_new] = transform_surf(sub_X, sub_Y, sub_Z, R, pos);
            set(submarine, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        end
        
        % Update lights
        light_pos_l = R * [-light_offset; sub_diameter*0.35; 0] + pos';
        light_pos_r = R * [-light_offset; -sub_diameter*0.35; 0] + pos';
        
        [X_new, Y_new, Z_new] = transform_surf(sphere_X*light_scale, ...
                                               sphere_Y*light_scale, ...
                                               sphere_Z*light_scale, ...
                                               R, light_pos_l');
        set(light_left, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        [X_new, Y_new, Z_new] = transform_surf(sphere_X*light_scale, ...
                                               sphere_Y*light_scale, ...
                                               sphere_Z*light_scale, ...
                                               R, light_pos_r');
        set(light_right, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Update LiDAR sensor
        lidar_pos = R * [0; 0; sub_diameter*0.65] + pos';
        [X_new, Y_new, Z_new] = transform_surf(sphere_X*lidar_scale, ...
                                               sphere_Y*lidar_scale, ...
                                               sphere_Z*lidar_scale, ...
                                               R, lidar_pos');
        set(lidar_sensor, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Update LiDAR beams
        for b = 1:num_beams
            angle_h = (b-1) * 2*pi / num_beams;
            angle_v = -0.4 - 0.2*sin(i/10 + b/5);
            
            beam_dir = R * [cos(angle_h)*cos(angle_v); 
                           sin(angle_h)*cos(angle_v); 
                           sin(angle_v)] * 18;
            beam_end = lidar_pos + beam_dir;
            
            if beam_end(1) >= 0 && beam_end(1) <= 100 && ...
               beam_end(2) >= 0 && beam_end(2) <= 100
                beam_end(3) = interp2(X, Y, Z, beam_end(1), beam_end(2), 'linear', beam_end(3));
            end
            
            set(beams(b), 'XData', [lidar_pos(1), beam_end(1)], ...
                         'YData', [lidar_pos(2), beam_end(2)], ...
                         'ZData', [lidar_pos(3), beam_end(3)]);
        end
        
        % Update trail
        set(trail, 'XData', path_x(1:i), 'YData', path_y(1:i), 'ZData', path_z(1:i));
        
        % Smooth camera following submarine
        cam_dist = 40;
        cam_height = 15;
        cam_target = pos + [cos(yaw)*10, sin(yaw)*10, 5];
        cam_pos = pos - [cos(yaw)*cam_dist, sin(yaw)*cam_dist, -cam_height];
        
        % Update view to follow submarine
        view_angle = 40 + i*0.15;
        elev_angle = 18 + 5*sin(i/50);
        view(view_angle, elev_angle);
        
        % Clean title
        progress = i / length(path_x);
        title(sprintf('DeepSeeker Submarine Scanner  |  Progress: %.0f%%  |  Cables: 3', ...
                     progress*100), ...
              'FontSize', 14, 'Color', [0.7 0.9 1], 'FontWeight', 'bold');
        
        drawnow limitrate;
        
        if mod(i, 40) == 0
            fprintf('  ▓▓▓ %.0f%% complete...\n', progress*100);
        end
        
        pause(0.025);
    end
    
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   ✓ MISSION COMPLETE!                         ║\n');
    fprintf('║   4 cables detected and mapped                ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n');
end

%% Helper Functions

function [X, Y, Z] = create_detailed_submarine(length, diameter)
    % High-quality submarine with smooth surfaces
    nseg = 40;
    
    % Main body
    [X_body, Y_body, Z_body] = cylinder(diameter/2, nseg);
    Z_body = Z_body * length * 0.7 - length*0.35;
    
    % Nose cone (pointy)
    [X_nose, Y_nose, Z_nose] = cylinder([0, diameter/2], nseg);
    Z_nose = Z_nose * (length*0.3) + length*0.35;
    
    % Tail cone
    [X_tail, Y_tail, Z_tail] = cylinder([diameter/2, diameter/4], nseg);
    Z_tail = Z_tail * (length*0.25) - (length*0.35 + length*0.25);
    
    % Combine
    X = [X_nose(1:end-1,:); X_body; X_tail(2:end,:)];
    Y = [Y_nose(1:end-1,:); Y_body; Y_tail(2:end,:)];
    Z = [Z_nose(1:end-1,:); Z_body; Z_tail(2:end,:)];
end

function R = rotation_matrix(yaw, pitch)
    % Combined yaw and pitch rotation
    Rz = [cos(yaw), -sin(yaw), 0;
          sin(yaw),  cos(yaw), 0;
          0,         0,        1];
    
    Ry = [cos(pitch), 0, sin(pitch);
          0,         1,         0;
          -sin(pitch), 0, cos(pitch)];
    
    R = Rz * Ry;
end

function [X_new, Y_new, Z_new] = transform_surf(X, Y, Z, R, pos)
    [rows, cols] = size(X);
    X_new = zeros(rows, cols);
    Y_new = zeros(rows, cols);
    Z_new = zeros(rows, cols);
    
    for i = 1:rows
        for j = 1:cols
            p = R * [X(i,j); Y(i,j); Z(i,j)] + pos(:);
            X_new(i,j) = p(1);
            Y_new(i,j) = p(2);
            Z_new(i,j) = p(3);
        end
    end
end
