%% Import and Animate Actual Submarine CAD Model
% This script imports your Submarine.step file and animates it scanning

function animate_real_submarine()
    
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   IMPORTING YOUR SUBMARINE CAD MODEL          ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
    
    %% Try to import STEP file
    step_file = 'Submarine.step';
    
    if ~exist(step_file, 'file')
        error('❌ Submarine.step not found! Please ensure it''s in: %s', pwd);
    end
    
    fprintf('⚙  Found: %s\n', step_file);
    fprintf('⚙  Attempting to import CAD geometry...\n\n');
    
    % Try different import methods
    submarine_model = [];
    use_method = 0;
    
    % Method 1: Try importGeometry (Simscape Multibody)
    if exist('importGeometry', 'file')
        try
            fprintf('   Trying importGeometry...\n');
            geo = importGeometry(step_file);
            submarine_model.vertices = geo.Points;
            submarine_model.faces = geo.ConnectivityList;
            use_method = 1;
            fprintf('   ✓ Success with importGeometry!\n');
        catch ME
            fprintf('   ⚠ importGeometry failed: %s\n', ME.message);
        end
    end
    
    % Method 2: Try STL export
    if use_method == 0
        fprintf('   ⚠ STEP import requires Simscape Multibody License\n');
        fprintf('   ℹ  Please export your Submarine.step as Submarine.stl\n');
        fprintf('   ℹ  Then place Submarine.stl in this folder\n\n');
        
        % Check for STL
        stl_file = 'Submarine.stl';
        if exist(stl_file, 'file')
            fprintf('   Found Submarine.stl! Loading...\n');
            try
                TR = stlread(stl_file);
                submarine_model.vertices = TR.Points;
                submarine_model.faces = TR.ConnectivityList;
                use_method = 2;
                fprintf('   ✓ Success with STL!\n');
            catch
                fprintf('   ❌ STL read failed\n');
            end
        end
    end
    
    % Method 3: Use procedural model matching your design
    if use_method == 0
        fprintf('   ℹ  Using procedural submarine model\n');
        fprintf('   ℹ  For best results, export as STL from CAD software\n\n');
        use_method = 3;
    end
    
    %% Setup environment
    fprintf('\n⚙  Building underwater scene...\n');
    
    [X, Y] = meshgrid(0:2:100, 0:2:100);
    Z = -50 + 6*sin(X/10).*cos(Y/12) + 3*sin(X/8) + randn(size(X))*0.6;
    
    % Create smooth path
    t = linspace(0, 4*pi, 300);
    path_x = 50 + 28*sin(t);
    path_y = 50 + 18*sin(2*t);
    path_z = -18 - 6*sin(t/2);
    path_yaw = atan2(diff([path_y, path_y(1)]), diff([path_x, path_x(1)]));
    path_yaw = [path_yaw, path_yaw(end)];
    
    %% Create figure
    fig = figure('Name', 'Submarine CAD Model Animation', ...
                 'Position', [100, 50, 1600, 900], ...
                 'Color', [0.02 0.06 0.10]);
    
    ax = axes('Position', [0.05 0.08 0.9 0.87]);
    hold on;
    view(45, 18);
    
    set(ax, 'Color', [0.02 0.06 0.10]);
    set(ax, 'XColor', [0.3 0.4 0.5], 'YColor', [0.3 0.4 0.5], 'ZColor', [0.3 0.4 0.5]);
    set(ax, 'GridColor', [0.2 0.3 0.4], 'GridAlpha', 0.15);
    grid on;
    
    % Seabed
    surf(X, Y, Z, 'FaceColor', [0.3 0.24 0.18], 'EdgeColor', 'none', ...
         'FaceAlpha', 0.75, 'AmbientStrength', 0.4);
    
    % Cables
    for c = 1:3
        cx = linspace(15, 85, 50) + randn(1, 50)*2;
        cy = 25 + c*16 + randn(1, 50)*2;
        cz = interp2(X, Y, Z, cx, cy, 'linear', -50) + 0.15;
        plot3(cx, cy, cz, 'Color', [0.85 0.4 0.15], 'LineWidth', 3.5);
    end
    
    %% Create/Import submarine
    
    if use_method == 3
        % Procedural submarine matching design
        [sub_verts, sub_faces] = create_submarine_cad_style();
    else
        % Use imported model
        sub_verts = submarine_model.vertices;
        sub_faces = submarine_model.faces;
        
        % Scale to 60cm length
        bbox = [max(sub_verts(:,1)) - min(sub_verts(:,1)), ...
                max(sub_verts(:,2)) - min(sub_verts(:,2)), ...
                max(sub_verts(:,3)) - min(sub_verts(:,3))];
        
        scale = 0.6 / bbox(1);  % 60cm submarine
        sub_verts = sub_verts * scale;
        
        % Center at origin
        sub_verts = sub_verts - mean(sub_verts, 1);
        
        fprintf('   Model stats:\n');
        fprintf('     Vertices: %d\n', size(sub_verts, 1));
        fprintf('     Faces: %d\n', size(sub_faces, 1));
        fprintf('     Dimensions: %.2f × %.2f × %.2f m\n', bbox*scale);
    end
    
    % Create submarine patch
    submarine = patch('Faces', sub_faces, 'Vertices', sub_verts, ...
                     'FaceColor', [0.92 0.95 0.98], ...  % Bright white-blue
                     'EdgeColor', 'none', ...
                     'FaceAlpha', 1, ...
                     'FaceLighting', 'gouraud', ...
                     'SpecularStrength', 0.9, ...
                     'DiffuseStrength', 0.75, ...
                     'AmbientStrength', 0.7, ...
                     'SpecularExponent', 25);
    
    % Add glowing elements
    [sphere_X, sphere_Y, sphere_Z] = sphere(12);
    
    % Front lights
    light_L = surf(sphere_X*0.035 - 0.25, sphere_Y*0.035 + 0.05, sphere_Z*0.035, ...
                  'FaceColor', [1 1 0.7], 'EdgeColor', 'none', ...
                  'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                  'AmbientStrength', 1);
    
    light_R = surf(sphere_X*0.035 - 0.25, sphere_Y*0.035 - 0.05, sphere_Z*0.035, ...
                  'FaceColor', [1 1 0.7], 'EdgeColor', 'none', ...
                  'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                  'AmbientStrength', 1);
    
    % LiDAR on top
    lidar = surf(sphere_X*0.04, sphere_Y*0.04, sphere_Z*0.04 + 0.1, ...
                'FaceColor', [0.3 0.7 1], 'EdgeColor', 'none', ...
                'FaceAlpha', 1, 'FaceLighting', 'gouraud', ...
                'AmbientStrength', 0.95);
    
    % LiDAR beams
    num_beams = 20;
    beams = zeros(1, num_beams);
    for b = 1:num_beams
        beams(b) = plot3([0 0], [0 0], [0 0], 'Color', [0.4 0.85 1], 'LineWidth', 1.5);
    end
    
    % Trail
    trail = plot3(path_x(1), path_y(1), path_z(1), ...
                 'Color', [0.5 0.8 1 0.6], 'LineWidth', 2.5, 'LineStyle', '--');
    
    % Lighting
    light('Position', [50 50 10], 'Style', 'local', 'Color', [0.7 0.8 0.9]);
    light('Position', [30 70 -5], 'Style', 'local', 'Color', [0.5 0.6 0.7]);
    light('Position', [70 30 0], 'Style', 'local', 'Color', [0.6 0.7 0.8]);
    lighting gouraud;
    material([0.6 0.8 0.5 30 0.95]);
    
    xlim([0 100]); ylim([0 100]); zlim([min(Z(:))-5, 5]);
    xlabel('X (m)', 'FontSize', 11, 'Color', [0.6 0.7 0.8]);
    ylabel('Y (m)', 'FontSize', 11, 'Color', [0.6 0.7 0.8]);
    zlabel('Depth (m)', 'FontSize', 11, 'Color', [0.6 0.7 0.8]);
    
    %% Animation
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║   🎬 ANIMATING SUBMARINE                       ║\n');
    fprintf('╚════════════════════════════════════════════════╝\n\n');
    
    % Store original vertices
    sub_verts_orig = sub_verts;
    
    for i = 1:length(path_x)
        pos = [path_x(i), path_y(i), path_z(i)];
        yaw = path_yaw(i);
        pitch = sin(i/20) * 0.08;
        
        % Rotation matrices
        Rz = [cos(yaw), -sin(yaw), 0;
              sin(yaw),  cos(yaw), 0;
              0,         0,        1];
        
        Ry = [cos(pitch), 0, sin(pitch);
              0,         1,         0;
              -sin(pitch), 0, cos(pitch)];
        
        R = Rz * Ry;
        
        % Transform submarine
        verts_new = (R * sub_verts_orig')' + repmat(pos, size(sub_verts_orig, 1), 1);
        set(submarine, 'Vertices', verts_new);
        
        % Transform lights
        light_pos_L = R * [-0.25; 0.05; 0] + pos';
        light_pos_R = R * [-0.25; -0.05; 0] + pos';
        
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*0.035, sphere_Y*0.035, ...
                                                  sphere_Z*0.035, R, light_pos_L');
        set(light_L, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*0.035, sphere_Y*0.035, ...
                                                  sphere_Z*0.035, R, light_pos_R');
        set(light_R, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Transform LiDAR
        lidar_pos = R * [0; 0; 0.1] + pos';
        [X_new, Y_new, Z_new] = transform_sphere(sphere_X*0.04, sphere_Y*0.04, ...
                                                  sphere_Z*0.04, R, lidar_pos');
        set(lidar, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
        
        % Update LiDAR beams
        for b = 1:num_beams
            angle = (b-1) * 2*pi / num_beams;
            beam_dir = R * [cos(angle)*0.5; sin(angle)*0.5; -1] * 16;
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
        
        % Smooth camera
        view(40 + i*0.15, 18 + 4*sin(i/45));
        
        % Title
        title(sprintf('Submarine CAD Model Animation  |  %.0f%% Complete', ...
                     i/length(path_x)*100), ...
              'FontSize', 14, 'Color', [0.7 0.9 1], 'FontWeight', 'bold');
        
        drawnow limitrate;
        
        if mod(i, 30) == 0
            fprintf('  ▓ %.0f%%\n', i/length(path_x)*100);
        end
        
        pause(0.03);
    end
    
    fprintf('\n✓ Animation complete!\n\n');
end

%% Helper Functions

function [vertices, faces] = create_submarine_cad_style()
    % Create high-quality submarine matching CAD design
    
    % Parameters based on your image
    length = 0.6;
    diameter = 0.12;
    
    % Main body
    nseg = 36;
    nlen = 30;
    
    theta = linspace(0, 2*pi, nseg);
    body_sections = [];
    
    % Body profile (smooth)
    z_profile = linspace(-length/2, length/2, nlen);
    
    for i = 1:nlen
        z = z_profile(i);
        
        % Radius varies along length
        if z > length/3
            % Nose cone
            r = diameter/2 * (1 - (z - length/3) / (length/2 - length/3))^0.7;
        elseif z < -length/3
            % Tail cone
            r = diameter/2 * (1 - abs(z + length/3) / (length/2 - length/3))^0.5 * 0.6;
        else
            % Main body
            r = diameter/2;
        end
        
        x = r * cos(theta);
        y = r * sin(theta);
        z_vec = ones(size(theta)) * z;
        
        body_sections = [body_sections; [x', y', z_vec']];
    end
    
    % Create faces
    vertices = body_sections;
    faces = [];
    
    for i = 1:(nlen-1)
        for j = 1:(nseg-1)
            v1 = (i-1)*nseg + j;
            v2 = (i-1)*nseg + j + 1;
            v3 = i*nseg + j + 1;
            v4 = i*nseg + j;
            
            faces = [faces; v1 v2 v3; v1 v3 v4];
        end
        
        % Wrap around
        v1 = (i-1)*nseg + nseg;
        v2 = (i-1)*nseg + 1;
        v3 = i*nseg + 1;
        v4 = i*nseg + nseg;
        
        faces = [faces; v1 v2 v3; v1 v3 v4];
    end
end

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
