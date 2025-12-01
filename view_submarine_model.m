%% Import and Preview Submarine STL Model
% Loads the submarine CAD model and shows it

clear; clc; close all;

fprintf('=== Submarine STL Model Viewer ===\n');

% Try different file formats
stl_files = {'submarine.stl', 'Submarine.stl', 'Submarine.step'};
model_loaded = false;

for i = 1:length(stl_files)
    if exist(stl_files{i}, 'file')
        fprintf('Found file: %s\n', stl_files{i});
        try
            if endsWith(stl_files{i}, '.stl')
                TR = stlread(stl_files{i});
            elseif endsWith(stl_files{i}, '.step')
                fprintf('  Note: STEP file requires Simscape Multibody or CAD import toolbox\n');
                fprintf('  Please export the model as .stl from your CAD software\n');
                continue;
            end
            model_loaded = true;
            fprintf('✓ Model loaded successfully!\n');
            break;
        catch ME
            fprintf('  ⚠ Error loading: %s\n', ME.message);
        end
    end
end

if ~model_loaded
    fprintf('\n⚠ No STL model found. Creating example submarine geometry...\n');
    % Create example submarine
    [X, Y, Z] = create_example_submarine();
    
    figure('Name', 'Example Submarine', 'Position', [100, 100, 1200, 700], ...
           'Color', [0.02 0.1 0.15]);
    
    surf(X, Y, Z, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none', ...
         'FaceAlpha', 0.9, 'FaceLighting', 'gouraud');
    
    camlight('headlight'); 
    lighting gouraud;
    title('Example Submarine 3D Model (Procedural)', 'FontSize', 16, 'Color', [0.7 0.9 1]);
    xlabel('X (m)', 'Color', [0.6 0.8 0.9]); 
    ylabel('Y (m)', 'Color', [0.6 0.8 0.9]); 
    zlabel('Z (m)', 'Color', [0.6 0.8 0.9]);
    axis equal; grid on; rotate3d on;
    set(gca, 'Color', [0.02 0.1 0.15]);
    set(gca, 'XColor', [0.3 0.5 0.6], 'YColor', [0.3 0.5 0.6], 'ZColor', [0.3 0.5 0.6]);
    
    fprintf('\nTo use your STL model:\n');
    fprintf('  1. Export Submarine.step as submarine.stl from CAD software\n');
    fprintf('  2. Place submarine.stl in: %s\n', pwd);
    fprintf('  3. Run this script again\n');
    return;
end

% Display the model
fprintf('\nModel statistics:\n');
fprintf('  Vertices: %d\n', size(TR.Points, 1));
fprintf('  Faces: %d\n', size(TR.ConnectivityList, 1));

% Get bounding box
vertices = TR.Points;
bbox_min = min(vertices);
bbox_max = max(vertices);
dimensions = bbox_max - bbox_min;

fprintf('  Dimensions: [%.3f, %.3f, %.3f] m\n', dimensions);
fprintf('  Center: [%.3f, %.3f, %.3f]\n', mean(vertices));

% Create figure
figure('Name', 'Submarine 3D Model', 'Position', [100, 100, 1400, 800], ...
       'Color', [0.02 0.1 0.15]);

% Subplot 1: Original model
subplot(1, 2, 1);
trisurf(TR, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.9);
camlight('headlight'); lighting gouraud;
title('Original Model', 'FontSize', 14, 'Color', [0.7 0.9 1]);
xlabel('X (m)', 'Color', [0.6 0.8 0.9]); 
ylabel('Y (m)', 'Color', [0.6 0.8 0.9]); 
zlabel('Z (m)', 'Color', [0.6 0.8 0.9]);
axis equal; grid on; rotate3d on;
set(gca, 'Color', [0.02 0.1 0.15]);
set(gca, 'XColor', [0.3 0.5 0.6], 'YColor', [0.3 0.5 0.6], 'ZColor', [0.3 0.5 0.6]);

% Subplot 2: Scaled and centered (for simulation)
subplot(1, 2, 2);
target_length = 0.6;  % 60cm submarine
scale = target_length / dimensions(1);
vertices_scaled = (vertices - mean(vertices)) * scale;

trisurf(TR.ConnectivityList, vertices_scaled(:,1), vertices_scaled(:,2), vertices_scaled(:,3), ...
        'FaceColor', [0.85 0.9 0.95], 'EdgeColor', 'none', 'FaceAlpha', 0.95);
camlight('headlight'); lighting gouraud;
title(sprintf('Scaled for Simulation (%.0f cm)', target_length*100), ...
      'FontSize', 14, 'Color', [0.7 0.9 1]);
xlabel('X (m)', 'Color', [0.6 0.8 0.9]); 
ylabel('Y (m)', 'Color', [0.6 0.8 0.9]); 
zlabel('Z (m)', 'Color', [0.6 0.8 0.9]);
axis equal; grid on; rotate3d on;
set(gca, 'Color', [0.02 0.1 0.15]);
set(gca, 'XColor', [0.3 0.5 0.6], 'YColor', [0.3 0.5 0.6], 'ZColor', [0.3 0.5 0.6]);

fprintf('\n✓ Model displayed successfully!\n');
fprintf('  Rotate with mouse to view from different angles\n');

function [X, Y, Z] = create_example_submarine()
    % Create procedural submarine for demonstration
    nseg = 32;
    
    % Body
    [X_body, Y_body, Z_body] = cylinder(0.075, nseg);
    Z_body = Z_body * 0.6 - 0.3;
    
    % Nose
    [X_nose, Y_nose, Z_nose] = cylinder([0, 0.075], nseg);
    Z_nose = Z_nose * 0.15 + 0.3;
    
    % Tail
    [X_tail, Y_tail, Z_tail] = cylinder([0.075, 0.04], nseg);
    Z_tail = Z_tail * 0.15 - 0.45;
    
    % Combine
    X = [X_nose(1:end-1,:); X_body; X_tail(2:end,:)];
    Y = [Y_nose(1:end-1,:); Y_body; Y_tail(2:end,:)];
    Z = [Z_nose(1:end-1,:); Z_body; Z_tail(2:end,:)];
end
