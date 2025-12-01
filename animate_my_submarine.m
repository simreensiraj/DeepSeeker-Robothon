%% ANIMATE DEEPSEEKER MODEL - FULL FEATURED
% Loads DeepSeeker STL and animates it underwater with scanning

function animate_my_submarine()
    
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   LOADING DEEPSEEKER FOR ANIMATION            ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
    
    %% Load DeepSeeker STL model
    stl_file = 'Submarine.stl';
    
    if ~exist(stl_file, 'file')
        error('❌ Submarine.stl not found!');
    end
    
    fprintf('⚙  Loading %s...\n', stl_file);
    TR = stlread(stl_file);
    sub_verts = TR.Points;
    sub_faces = TR.ConnectivityList;
    
    fprintf('✓ Loaded: %d vertices, %d faces\n', size(sub_verts,1), size(sub_faces,1));
    
    % Scale HUGE - make it 20 meters long!
    dims = max(sub_verts) - min(sub_verts);
    scale = 20.0 / dims(1);  % 20 METERS - MASSIVE!
    sub_verts = sub_verts * scale;
    sub_verts = sub_verts - mean(sub_verts, 1);
    
    fprintf('✓ Scaled to: %.2f × %.2f × %.2f m (HUGE!)\n', dims * scale);
    
    %% Create underwater environment
    fprintf('⚙  Building underwater scene...\n');
    
    [X, Y] = meshgrid(0:2:100, 0:2:100);
    Z = -50 + 6*sin(X/10).*cos(Y/12) + 3*sin(X/8) + randn(size(X))*0.6;
    
    % Smooth path for DeepSeeker
    t = linspace(0, 4*pi, 350);
    path_x = 50 + 28*sin(t);
    path_y = 50 + 18*sin(2*t);
    path_z = -18 - 6*sin(t/2);
    path_yaw = atan2(diff([path_y, path_y(1)]), diff([path_x, path_x(1)]));
    path_yaw = [path_yaw, path_yaw(end)];
    
    %% Create figure
    fig = figure('Name', 'DeepSeeker - Underwater Scanner', ...
                 'Position', [50, 50, 1600, 900], ...
                 'Color', [0.01 0.02 0.08]);
    
    ax = axes('Position', [0.05 0.08 0.9 0.87]);
    hold on;
    view(45, 18);
    
    % TECHNO underwater atmosphere - dark with neon accents
    set(ax, 'Color', [0.01 0.02 0.08]);
    set(ax, 'XColor', [0 0.8 1], 'YColor', [0 0.8 1], ...
        'ZColor', [0 0.8 1]);
    set(ax, 'GridColor', [0 0.8 1], 'GridAlpha', 0.4, 'LineWidth', 1.5);
    grid on;
    
    % Seabed with dark metallic look
    surf(X, Y, Z, 'FaceColor', [0.08 0.12 0.18], ...
         'EdgeColor', 'none', 'FaceAlpha', 0.9, ...
         'AmbientStrength', 0.3);
    
    % Add NEON GRID on seabed
    fprintf('⚡ Creating techno grid...\n');
    grid_spacing = 10;
    for i = 0:grid_spacing:100
        zi = interp2(X, Y, Z, i*ones(1,21), 0:5:100, 'linear', -50);
        plot3(ones(1,21)*i, 0:5:100, zi, ...
              'Color', [0 0.8 1 0.35], 'LineWidth', 1);
        
        zi = interp2(X, Y, Z, 0:5:100, i*ones(1,21), 'linear', -50);
        plot3(0:5:100, ones(1,21)*i, zi, ...
              'Color', [0 0.8 1 0.35], 'LineWidth', 1);
    end
    
    % Undersea cables with GLOWING neon effect
    fprintf('⚙  Placing glowing cables...\n');
    for c = 1:3
        cx = linspace(15, 85, 50) + randn(1, 50)*2;
        cy = 25 + c*16 + randn(1, 50)*2;
        cz = interp2(X, Y, Z, cx, cy, 'linear', -50) + 0.15;
        
        % Outer glow
        plot3(cx, cy, cz, 'Color', [1 0.3 0 0.2], 'LineWidth', 8);
        % Middle glow
        plot3(cx, cy, cz, 'Color', [1 0.5 0 0.5], 'LineWidth', 5);
        % Core
        plot3(cx, cy, cz, 'Color', [1 0.8 0.2], 'LineWidth', 2.5);
    end
    
    %% Create DEEPSEEKER with TECHNO aesthetics
    
    % Main DeepSeeker body (sleek metallic silver-blue)
    submarine = patch('Faces', sub_faces, 'Vertices', sub_verts, ...
                     'FaceColor', [0.75 0.85 0.95], ...  % Bright silver-blue
                     'EdgeColor', 'none', ...
                     'FaceAlpha', 1, ...
                     'FaceLighting', 'gouraud', ...
                     'SpecularStrength', 0.95, ...
                     'DiffuseStrength', 0.7, ...
                     'AmbientStrength', 0.7, ...
                     'SpecularExponent', 35);
    
    % Add GLOWING colored components
    [sphere_X, sphere_Y, sphere_Z] = sphere(14);
    
    % BRIGHT YELLOW/ORANGE front lights (glowing)
    light_L = surf(sphere_X*1.0 - 8, sphere_Y*1.0 + 2, sphere_Z*1.0, ...
                  'FaceColor', [1 0.9 0.2], ...  % Bright yellow
                  'EdgeColor', 'none', 'FaceAlpha', 1, ...
                  'FaceLighting', 'gouraud', 'AmbientStrength', 1.0);
    
    light_R = surf(sphere_X*1.0 - 8, sphere_Y*1.0 - 2, sphere_Z*1.0, ...
                  'FaceColor', [1 0.9 0.2], ...  % Bright yellow (matching)
                  'EdgeColor', 'none', 'FaceAlpha', 1, ...
                  'FaceLighting', 'gouraud', 'AmbientStrength', 1.0);
    
    % NEON BLUE LiDAR sensor on top (glowing)
    lidar = surf(sphere_X*1.2, sphere_Y*1.2, sphere_Z*1.2 + 3, ...
                'FaceColor', [0 0.9 1], ...  % Bright cyan
                'EdgeColor', 'none', 'FaceAlpha', 1, ...
                'FaceLighting', 'gouraud', 'AmbientStrength', 1.0);
    
    % NEON RED tail light/propeller marker (glowing)
    tail_light = surf(sphere_X*0.8 + 9, sphere_Y*0.8, sphere_Z*0.8, ...
                     'FaceColor', [1 0.1 0.3], ...  % Hot pink/red
                     'EdgeColor', 'none', 'FaceAlpha', 1, ...
                     'FaceLighting', 'gouraud', 'AmbientStrength', 1.0);
    
    % BRIGHT CYAN scanning beams (laser-like)
    num_beams = 24;
    beams = zeros(1, num_beams);
    for b = 1:num_beams
        beams(b) = plot3([0 0], [0 0], [0 0], ...
                        'Color', [0 1 1], ...
                        'LineWidth', 2, ...
                        'LineStyle', '-');
    end
    
    % DeepSeeker trail with NEON glow
    trail = plot3(path_x(1), path_y(1), path_z(1), ...
                 'Color', [0 1 1 0.7], ...
                 'LineWidth', 3, ...
                 'LineStyle', '-');
    
    % TECHNO lighting - cool neon blue tones
    light('Position', [50 50 10], 'Style', 'local', 'Color', [0.3 0.6 1]);
    light('Position', [30 70 -5], 'Style', 'local', 'Color', [0 0.8 1]);
    light('Position', [70 30 5], 'Style', 'local', 'Color', [0.2 0.7 0.9]);
    lighting gouraud;
    material([0.6 0.9 0.6 30 0.95]);
    
    xlim([0 100]); ylim([0 100]); zlim([min(Z(:))-5, 5]);
    xlabel('X (m)', 'FontSize', 12, 'Color', [0 0.9 1], 'FontWeight', 'bold');
    ylabel('Y (m)', 'FontSize', 12, 'Color', [0 0.9 1], 'FontWeight', 'bold');
    zlabel('Depth (m)', 'FontSize', 12, 'Color', [0 0.9 1], 'FontWeight', 'bold');
    
    %% Animation loop
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   🎬 ANIMATING DEEPSEEKER                      ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
    
    sub_verts_orig = sub_verts;
    
    for i = 1:length(path_x)
        pos = [path_x(i), path_y(i), path_z(i)];
        yaw = path_yaw(i);
        pitch = sin(i/20) * 0.08;
        roll = sin(i/30) * 0.05;
        
        % Full 3D rotation
        Rz = [cos(yaw), -sin(yaw), 0;
              sin(yaw),  cos(yaw), 0;
              0,         0,        1];
        
        Ry = [cos(pitch), 0, sin(pitch);
              0,         1,         0;
              -sin(pitch), 0, cos(pitch)];
        
        Rx = [1,    0,          0;
              0, cos(roll), -sin(roll);
              0, sin(roll),  cos(roll)];
        
        R = Rz * Ry * Rx;
        
        % Transform DeepSeeker
        verts_new = (R * sub_verts_orig')' + repmat(pos, size(sub_verts_orig, 1), 1);
        set(submarine, 'Vertices', verts_new);
        
        % Transform lights
        light_pos_L = R * [-8; 2; 0] + pos';
        light_pos_R = R * [-8; -2; 0] + pos';
        tail_pos = R * [9; 0; 0] + pos';
        
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*1.0, sphere_Y*1.0, ...
                                                  sphere_Z*1.0, R, light_pos_L');
        set(light_L, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*1.0, sphere_Y*1.0, ...
                                                  sphere_Z*1.0, R, light_pos_R');
        set(light_R, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*0.8, sphere_Y*0.8, ...
                                                  sphere_Z*0.8, R, tail_pos');
        set(tail_light, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Transform LiDAR
        lidar_pos = R * [0; 0; 3] + pos';
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*1.2, sphere_Y*1.2, ...
                                                  sphere_Z*1.2, R, lidar_pos');
        set(lidar, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Update scanning beams
        for b = 1:num_beams
            angle = (b-1) * 2*pi / num_beams + i/20;
            beam_dir = R * [cos(angle)*0.5; sin(angle)*0.5; -1] * 30;
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
        
        % Dynamic camera
        view(38 + i*0.12, 17 + 4*sin(i/50));
        
        % Title - TECHNO STYLE
        progress = i / length(path_x);
        title(sprintf('⚡ DEEPSEEKER SCANNER :: ACTIVE ⚡  |  %.0f%% SCAN  |  DEPTH: %.1fm', ...
                     progress*100, abs(pos(3))), ...
              'FontSize', 14, 'Color', [0 1 1], 'FontWeight', 'bold');
        
        drawnow limitrate;
        
        if mod(i, 35) == 0
            fprintf('  ▓▓ %.0f%%\n', progress*100);
        end
        
        pause(0.025);
    end
    
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   ✓ ANIMATION COMPLETE!                        ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
end

%% Helper function
function [X_new, Y_new, Z_new] = transform_sphere(X, Y, Z, R, pos)
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
