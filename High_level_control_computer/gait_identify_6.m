clear all;
clc;
close all;
addpath('../');
all_data = load('Wood_Euler_5_850.csv');
pause(1.5);
xx = 1:size(all_data,1);
xx = xx';

% Euler Cycle performed
eul_num = 5;

% Normalize starting with 1 for all flex data
% flex_data = max(all_data(:,1:4), 1);
flex_data = all_data(:,1:4);

% Four flex sensors
flex_1 = flex_data(:,1);
flex_2 = flex_data(:,2);
flex_3 = flex_data(:,3);
flex_4 = flex_data(:,4);

%IMU Data

accel_x = all_data(:,5);
accel_y = all_data(:,6);
accel_z = all_data(:,7);

mag_z = all_data(:,8);
mag_y = all_data(:,9);
mag_x = all_data(:,10);

%Indexes of faulty data
accel_x_errors = find(abs(accel_x) >= 200);
accel_y_errors = find(abs(accel_y) >= 200);
accel_z_errors = find(abs(accel_z) >= 200);

mag_z_errors = find(abs(mag_z) >= 363);
mag_y_errors = find(abs(mag_y) >= 363);
mag_x_errors = find(abs(mag_x) >= 363);

accel_x_clean = medfilt1(accel_x,5);
accel_y_clean = medfilt1(accel_y,5);
accel_z_clean = medfilt1(accel_z,5);

mag_z_clean = medfilt1(mag_z,5);
mag_y_clean = medfilt1(mag_y,5);
mag_x_clean = medfilt1(mag_x,5);

for ii=1:size(accel_x_errors)
accel_x(accel_x_errors(ii)) = accel_x_clean(accel_x_errors(ii));
end
for ii=1:size(accel_y_errors)
accel_y(accel_y_errors(ii)) = accel_y_clean(accel_y_errors(ii));
end
for ii=1:size(accel_z_errors)
accel_z(accel_z_errors(ii)) = accel_z_clean(accel_z_errors(ii));
end

for ii=1:size(mag_z_errors)
mag_z(mag_z_errors(ii)) = mag_z_clean(mag_z_errors(ii));
end
for ii=1:size(mag_y_errors)
mag_y(mag_y_errors(ii)) = mag_y_clean(mag_y_errors(ii));
end
for ii=1:size(mag_x_errors)
mag_x(mag_x_errors(ii)) = mag_x_clean(mag_x_errors(ii));
end

%Clean and Raw Data
figure;
subplot(3,1,1)
plot(xx, accel_x)
hold on
plot(xx, all_data(:,5))

subplot(3,1,2)
plot(xx, accel_y)
hold on
plot(xx, all_data(:,6))

subplot(3,1,3)
plot(xx, accel_z)
hold on
plot(xx, all_data(:,7))

figure;
subplot(3,1,1)
plot(xx, mag_z)
hold on 
plot(xx, all_data(:,8))

subplot(3,1,2)
plot(xx, mag_y)
hold on
plot(xx, all_data(:,9))

subplot(3,1,3)
plot(xx, mag_x)
hold on
plot(xx, all_data(:,10))


%Cleaned Data Only
figure;
subplot(3,1,1)
plot(xx, accel_x)

subplot(3,1,2)
plot(xx, accel_y)

subplot(3,1,3)
plot(xx, accel_z)


figure;
subplot(3,1,1)
plot(xx, mag_z)

subplot(3,1,2)
plot(xx, mag_y)

subplot(3,1,3)
plot(xx, mag_x)


all_data(:,5)=accel_x;
all_data(:,6)=accel_y;
all_data(:,7)=accel_z;
all_data(:,8)=mag_z;
all_data(:,9)=mag_y;
all_data(:,10)=mag_x;

%%

figure;
subplot(4,1,1)
plot(xx, flex_1(:,1), 'DisplayName','Signal')

subplot(4,1,2)
plot(xx, flex_2(:,1), 'DisplayName','Signal')

subplot(4,1,3)
plot(xx, flex_3(:,1), 'DisplayName','Signal')

subplot(4,1,4)
plot(xx, flex_4(:,1), 'DisplayName','Signal')

% After seeing the plot implement signal correction here
% flex_3(1:156) = 0.963; % Euler_2 - Dont know time
% flex_4(1:220) = 0.963; % Euler_3 - 850ms
% flex_3(1:299) = 0.961;
% flex_4(1:460) = 0.951;
% flex_3(1:199) = 0.951;
% flex_4(1:195) = 0.951;
% flex_3(1:170) = 0.951;
% flex_3(1:388) = 0.965;
% flex_3(5264:5297) = 1.1;
% flex_1(1:1116) = 0.951;
% flex_3(1:161) = 0.961;
% flex_3(271:500) = 0.961;
flex_3(1:205) = 0.961;

% Plot signal again to verify

figure;

subplot(4,1,1)
plot(xx, flex_1(:,1), 'DisplayName','Signal')

subplot(4,1,2)
plot(xx, flex_2(:,1), 'DisplayName','Signal')

subplot(4,1,3)
plot(xx, flex_3(:,1), 'DisplayName','Signal')

subplot(4,1,4)
plot(xx, flex_4(:,1), 'DisplayName','Signal')

% Finding range of signal

range_flex_1 = max(flex_1) - min(flex_1);
range_flex_2 = max(flex_2) - min(flex_2);
range_flex_3 = max(flex_3) - min(flex_3);
range_flex_4 = max(flex_4) - min(flex_4);

% Threshold

threshold_1 = (min(flex_1) + range_flex_1/3);
threshold_2 = (min(flex_2) + range_flex_2/3);
threshold_3 = (min(flex_3) + range_flex_3/3.5);
threshold_4 = (min(flex_4) + range_flex_4/3);

% 1st attempt smoothing square output
for ii = 1:size(all_data,1)

    if flex_1(ii) >= threshold_1
        smooth_flex_1(ii,1) = 1;
    else
        smooth_flex_1(ii,1) = 0;
    end

    if flex_2(ii) >= threshold_2
        smooth_flex_2(ii,1) = 1;
    else
        smooth_flex_2(ii,1) = 0;
    end

    if flex_3(ii) >= threshold_3
        smooth_flex_3(ii,1) = 1;
    else
        smooth_flex_3(ii,1) = 0;
    end

    if flex_4(ii) >= threshold_4
        smooth_flex_4(ii,1) = 1;
    else
        smooth_flex_4(ii,1) = 0;
    end

end

% Smoothened plot

figure;
subplot(4,1,1)
plot(xx, smooth_flex_1(:,1), 'DisplayName','Signal')

subplot(4,1,2)
plot(xx, smooth_flex_2(:,1), 'DisplayName','Signal')

subplot(4,1,3)
plot(xx, smooth_flex_3(:,1), 'DisplayName','Signal')

subplot(4,1,4)
plot(xx, smooth_flex_4(:,1), 'DisplayName','Signal')

% Incase jitter - Median or Moving Filter

% Median Filter

med_filt_width = 7;
clean_data_1 = medfilt1(smooth_flex_1, med_filt_width);
clean_data_2 = medfilt1(smooth_flex_2, med_filt_width);
clean_data_3 = medfilt1(smooth_flex_3, med_filt_width);
clean_data_4 = medfilt1(smooth_flex_4, med_filt_width);

figure;
subplot(4,1,1)
plot(xx, clean_data_1(:,1), 'DisplayName','Signal')

subplot(4,1,2)
plot(xx, clean_data_2(:,1), 'DisplayName','Signal')

subplot(4,1,3)
plot(xx, clean_data_3(:,1), 'DisplayName','Signal')

subplot(4,1,4)
plot(xx, clean_data_4(:,1), 'DisplayName','Signal')

% Compare Cleaned signal vs Original Signal

figure

plot(xx, clean_data_1(:,1) + 0.1, 'DisplayName','Cleaned Signal','Color','r')
hold on
plot(xx, flex_1(:,1), 'DisplayName','Signal','Color','b')
legend
title('Sensor 1')

figure

plot(xx, clean_data_2(:,1) + 0.1, 'DisplayName','Cleaned Signal','Color','r')
hold on
plot(xx, flex_2(:,1), 'DisplayName','Signal','Color','b')
legend
title('Sensor 2')

figure

plot(xx, clean_data_3(:,1) + 0.1, 'DisplayName','Cleaned Signal','Color','r')
hold on
plot(xx, flex_3(:,1), 'DisplayName','Signal','Color','b')
legend
title('Sensor 3')

figure

plot(xx, clean_data_4(:,1) + 0.1, 'DisplayName','Cleaned Signal','Color','r')
hold on
plot(xx, flex_4(:,1), 'DisplayName','Signal','Color','b')
legend
title('Sensor 4')

%%
% % [] Clean IMU data
% 
% for ii = 5:14
% 
% check_imu_datas = all_data(:,ii);
% check_jitters = diff(check_imu_datas);



% Find all states index

for nn = 1:16

    overlap_region = robot_state(clean_data_1,clean_data_2,clean_data_3,clean_data_4,nn);

    idx_logical_2 = find(overlap_region == 1);

    d = diff(idx_logical_2);

    switch_indices = find(d>10);
    start_idx = 1;

    for ii = 1:size(switch_indices,1)+1

        if ii ~= size(switch_indices,1)+1
            gaits_switch{nn,ii} = idx_logical_2(start_idx:switch_indices(ii));
            mean_idx_val(ii) = round(mean(idx_logical_2(start_idx:switch_indices(ii))));
            start_idx = switch_indices(ii) + 1;
        else
            gaits_switch{nn,ii} = idx_logical_2(start_idx:end);
            mean_idx_val(ii) = round(mean(idx_logical_2(start_idx:end)));
        end

    end

end

% Clean data of gaits

for nn = 1:size(gaits_switch,1)
    for mm = 1:size(gaits_switch,2)
        if nn == 1 && mm == 1
            gaits_switch{nn,mm} = [];
        end

        if size(gaits_switch{nn,mm},1) < 18
            gaits_switch{nn,mm} = [];
        end
    end
end

gaits_switch_new = cell(size(gaits_switch,1),size(gaits_switch,2));

for ii = 1:size(gaits_switch,1)
    % Find non-empty cells in this row
    nonEmptyMask = ~cellfun(@isempty, gaits_switch(ii,:));
    nonEmptyData = gaits_switch(ii, nonEmptyMask);

    % Place them starting from column 1 (left-aligned)
    if ~isempty(nonEmptyData)
        gaits_switch_new(ii, 1:numel(nonEmptyData)) = nonEmptyData;
    end
    % If the row is fully empty, C_new(i,:) stays as {} which is equivalent to []
end

state_order_all = load('state_order_3.mat');
state_order = state_order_all.state_order_3(eul_num,:); % Extract state order from loaded data

state_index = zeros(1,16);

for ii = 1:size(state_order,2)
    state_index(state_order(ii)) = state_index(state_order(ii)) + 1;
    curr_data_indices = gaits_switch_new{state_order(ii),state_index(state_order(ii))};
    key_data_indices{ii} = curr_data_indices;
    imu_data{ii} = all_data(curr_data_indices,5:14);
end
%%
% Calculate all average

% [1] Average change in theta's

for ii = 1:size(imu_data,2)
    diff_theta{ii} = diff(imu_data{1,ii}(:,4:6));

        for jj = 1:size(diff_theta{ii},1)

            if abs(diff_theta{ii}(jj,1)) > 300
                diff_theta{ii}(jj,1) = 360 - diff_theta{ii}(jj,1);
            end

        end

    avg_delta_theta{ii} = mean(diff_theta{ii})*size(imu_data{1,ii},1);
end

% [2] Average linear acceleration

for ii = 1:size(imu_data,2)
    avg_lin_accel{ii} = mean(imu_data{1,ii}(:,1:3));
end


% Adjusting tilt - Aligning z-axis so xy is planar.

init_theta = mean(all_data(1:20,8:10)); % Initial angles
z_init = [0;0;1];

for ii = 1:size(imu_data,2)

    avg_theta{ii} = mean(imu_data{1,ii}(:,4:6));
    delta_theta_wrt_initial = deg2rad(avg_theta{ii} - init_theta);

    R_z = [cos(delta_theta_wrt_initial(1)) -sin(delta_theta_wrt_initial(1)) 0; sin(delta_theta_wrt_initial(1)) cos(delta_theta_wrt_initial(1)) 0; 0 0 1];
    R_y = [cos(delta_theta_wrt_initial(2)) 0 sin(delta_theta_wrt_initial(2)); 0 1 0; -sin(delta_theta_wrt_initial(2)) 0 cos(delta_theta_wrt_initial(2))];
    R_x = [1 0 0; 0 cos(delta_theta_wrt_initial(3)) -sin(delta_theta_wrt_initial(3)); 0 sin(delta_theta_wrt_initial(3)) cos(delta_theta_wrt_initial(3))];

    R_eq = R_z*R_y*R_x;

    z_t = R_eq(:,3);

    n_vec = cross(z_t,z_init)/norm(cross(z_t,z_init));
    skew_mat = [0, -n_vec(3), n_vec(2); n_vec(3), 0, -n_vec(1); -n_vec(2), n_vec(1), 0];

    align_theta = atan2(n_vec'*cross(z_t,z_init), z_t'*z_init);

    Rod_n = eye(3) + sin(align_theta)*skew_mat + (1-cos(align_theta))*(skew_mat)^2;

    aligned_accel(:,ii) = Rod_n*avg_lin_accel{ii}';

    aligned_accel_x(ii) = aligned_accel(1,ii);
    aligned_accel_y(ii) = aligned_accel(2,ii);
    aligned_accel_z(ii) = aligned_accel(3,ii);

end

% [3] Body Displacement
% t = 0.450;
t = 0.850;
for ii = 1:size(imu_data,2)
    body_disp(ii,:) = 0.5*[aligned_accel_x(ii),aligned_accel_y(ii)]*[(t)^2;(t)^2];
end


% Edges Graph
kk = 0;
for ii = 1:16
    for jj = 1:16
        if ii ~= jj
            kk = kk + 1;
            edges_map(kk,:) = [ii,jj,kk];
        end
    end
end

% Motion Primitives
motion_primitive=zeros(240,3);
for ii = 1:size(state_order,2)-1

    [~, edge_index] = ismember([state_order(ii),state_order(ii+1)],...
        edges_map(:, 1:2), 'rows');

    motion_primitive(edge_index,:)=[aligned_accel_x(ii+1),aligned_accel_y(ii+1),avg_delta_theta{ii+1}(1)];

end

%%