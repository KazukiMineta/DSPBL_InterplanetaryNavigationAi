%% ============================================
%  2D Solar System + Moons (Dark Mode, No Scaling)
% ============================================
clear; clc; close all;

data = readtable("solar_system_with_moons_2d.csv");
bodies = unique(data.body);

figure('Color','k'); hold on; axis equal;
set(gca,'Color','k','XColor','w','YColor','w','GridColor',[0.3 0.3 0.3]);
grid on;

xlabel('X [km]','Color','w');
ylabel('Y [km]','Color','w');
title('2D Solar System with Moons (Dark Mode)','Color','w');

%% ============================================
% 太陽（原点固定）
%% ============================================
sun_radius = 8e6;
theta = linspace(0, 2*pi, 200);
fill(sun_radius*cos(theta), sun_radius*sin(theta), 'y', ...
    'EdgeColor','y','LineWidth',1.5);

%% 惑星と衛星の色
colors = lines(length(bodies));

%% ============================================
% 惑星＋衛星をすべて同じルールで描画
%% ============================================
for k = 1:length(bodies)
    name = bodies{k};
    idx = strcmp(data.body, name);

    x = data.x(idx);
    y = data.y(idx);

    % 軌道（細い実線）
    plot(x, y, 'Color', colors(k,:), 'LineWidth', 0.8);

    % 本体（小さな点）
    plot(x(end), y(end), 'o', ...
        'MarkerSize', 4, ...
        'MarkerFaceColor', colors(k,:), ...
        'MarkerEdgeColor','none');

    text(x(end), y(end), [' ' name], 'Color','w');
end
