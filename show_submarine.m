%% LOAD AND SHOW SUBMARINE - SIMPLE VERSION
clear; clc; close all;

fprintf('═════════════════════════════════════════════\n');
fprintf('  LOADING YOUR SUBMARINE MODEL\n');
fprintf('═════════════════════════════════════════════\n\n');

%% Load the STL file
stl_file = 'Submarine.stl';

if ~exist(stl_file, 'file')
    error('❌ Submarine.stl not found in: %s', pwd);
end

fprintf('✓ Found: %s\n', stl_file);
fprintf('⚙  Reading STL...\n');

TR = stlread(stl_file);
vertices = TR.Points;
faces = TR.ConnectivityList;

fprintf('✓ Loaded!\n');
fprintf('  Vertices: %d\n', size(vertices, 1));
fprintf('  Faces: %d\n', size(faces, 1));

%% Get model dimensions
bbox_min = min(vertices);
bbox_max = max(vertices);
dims = bbox_max - bbox_min;

fprintf('  Original size: %.2f × %.2f × %.2f m\n', dims);

%% Scale to 60cm
target_length = 0.6;
scale = target_length / dims(1);
vertices_scaled = vertices * scale;

% Center at origin
vertices_scaled = vertices_scaled - mean(vertices_scaled, 1);

fprintf('  Scaled to: %.2f × %.2f × %.2f m\n', dims * scale);

%% Create figure and show it
fprintf('\n⚙  Creating display...\n\n');

figure('Name', 'YOUR SUBMARINE MODEL', 'Position', [100, 100, 1400, 800], ...
       'Color', [0.02 0.06 0.1]);

%% Show the submarine
patch('Faces', faces, 'Vertices', vertices_scaled, ...
      'FaceColor', [0.9 0.95 1], ...
      'EdgeColor', 'none', ...
      'FaceAlpha', 1, ...
      'FaceLighting', 'gouraud', ...
      'SpecularStrength', 0.9, ...
      'DiffuseStrength', 0.7, ...
      'AmbientStrength', 0.6);

% Lighting
camlight('headlight');
camlight('right');
lighting gouraud;
material([0.6 0.8 0.5 25 0.9]);

% Styling
set(gca, 'Color', [0.02 0.06 0.1]);
set(gca, 'XColor', [0.4 0.5 0.6], 'YColor', [0.4 0.5 0.6], 'ZColor', [0.4 0.5 0.6]);
grid on;
axis equal;
view(45, 20);
rotate3d on;

xlabel('X (m)', 'Color', [0.7 0.8 0.9], 'FontSize', 12);
ylabel('Y (m)', 'Color', [0.7 0.8 0.9], 'FontSize', 12);
zlabel('Z (m)', 'Color', [0.7 0.8 0.9], 'FontSize', 12);

title('YOUR SUBMARINE - 3D CAD MODEL', 'Color', [0.7 0.9 1], ...
      'FontSize', 16, 'FontWeight', 'bold');

fprintf('═════════════════════════════════════════════\n');
fprintf('✓ SUBMARINE DISPLAYED!\n');
fprintf('  Rotate with mouse to view from all angles\n');
fprintf('═════════════════════════════════════════════\n');
