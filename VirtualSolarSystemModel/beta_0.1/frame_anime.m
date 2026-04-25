%% ============================================
%  2D Solar System + Moons Animation (with Trails)
%  Animation speed: 1 month = 1 second
% ============================================
clear; clc; close all;

data = readtable("solar_system_with_moons_2d.csv");
bodies = unique(data.body);

% 時系列
days = unique(data.day);
N = length(days);

% 色
colors = lines(length(bodies));

% 衛星リスト
moon_list = ["Moon","Phobos","Deimos","Io","Europa","Ganymede","Callisto", ...
             "Titan","Rhea","Iapetus","Titania","Oberon","Triton"];

% 惑星リスト
planet_names = bodies(~ismember(bodies, moon_list));

%% Figure settings
figure('Color','k'); hold on; axis equal;
set(gca,'Color','k','XColor','w','YColor','w','GridColor',[0.3 0.3 0.3]);
grid on;

xlabel('X [km]','Color','w');
ylabel('Y [km]','Color','w');
title('2D Solar System Animation (1 month = 1 sec)','Color','w');

%% 太陽（原点固定）
sun_radius = 8e6;
theta = linspace(0, 2*pi, 200);
fill(sun_radius*cos(theta), sun_radius*sin(theta), 'y', ...
    'EdgeColor','y','LineWidth',1.5);

%% プロットハンドル作成
h = struct();        % 現在位置
trail = struct();    % 軌跡
label = struct();    % 惑星名ラベル

for k = 1:length(bodies)
    name = bodies{k};

    % 現在位置
    h.(name) = plot(0, 0, 'o', ...
        'MarkerSize', 5, ...
        'MarkerFaceColor', colors(k,:), ...
        'MarkerEdgeColor', 'none');

    % 軌跡（細い線）
    trail.(name) = plot(0, 0, '-', ...
        'LineWidth', 0.5, ...
        'Color', colors(k,:));

    % 惑星名ラベル（衛星は表示しない）
    if any(strcmp(name, planet_names))
        label.(name) = text(0, 0, name, 'Color', 'w');
    end
end

%% ============================================
% アニメーションループ
% ============================================

% 1フレーム ≒ 0.608日 → 1か月(30日)を1秒で再生
pause_time = 0.02;   % ← ここが重要

for t = 1:N
    day = days(t);

    for k = 1:length(bodies)
        name = bodies{k};

        idx = strcmp(data.body, name) & data.day == day;
        x = data.x(idx);
        y = data.y(idx);

        % 現在位置更新
        set(h.(name), 'XData', x, 'YData', y);

        % 軌跡更新
        past = data(strcmp(data.body, name) & data.day <= day, :);
        set(trail.(name), 'XData', past.x, 'YData', past.y);

        % 惑星名ラベル更新
        if isfield(label, name)
            set(label.(name), 'Position', [x, y]);
        end
    end

    drawnow;
    pause(pause_time);
end
