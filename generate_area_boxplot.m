function [ output ] = generate_area_boxplot(num_tp)

cell_areas = cell(num_tp);
max_num_cell = 0;
for t = 1 : num_tp
    cd(['tp_' num2str(t)]);
    names = dir('**.tif');
    area_storage = zeros( size(names, 1), 1);
    if size(names, 1) > max_num_cell
        max_num_cell = size(names, 1);
    end
    for c = 1 : size(names, 1)
        filename = names(c).name;
        infoA = imfinfo(filename);
        width = infoA(1).Width;
        height = infoA(1).Height;
        num_z = size(infoA, 1);
        
        %make SIP
        blank = zeros(height,width);
        for z = 1 : num_z
            image = imread(filename, z, 'Info', infoA)/255;
            blank = image | blank;
        end
        area_storage(c, 1) = sum(sum(blank));
        
        
    end
    cell_areas{t} = area_storage;
    cd('..');
end

for t = 1 : num_tp
    this_tp = cell_areas{t};
    length = size(this_tp, 1);
    difference = max_num_cell - length;
    filler = zeros(difference, 1);
    filler(1:difference, 1) = nan;
    new_list = [this_tp ; filler];
    fprintf('OG list length at time %d: %d', length);
    fprintf('filler length: %d', size(filler, 1) );
    fprintf('list at time %d size %d \n', t, size(new_list, 1) );
    boxplot_matrix(:, t) = new_list;
end

%boxplot(boxplot_matrix(1:9, :) );%use 9 largest cells, use for generating boxplots

%use for generating raw data
reshaped_vector = reshape(boxplot_matrix(1:9, :), 1, 9*53);
timepoints =zeros(0,0);
for t = 1 : num_tp
    temp = zeros(1, 9);
    temp(1, 1:9) = t;
    timepoints = [timepoints temp];
end

scatter(timepoints, reshaped_vector);
title('Cell Spread Area Measurements');
xlabel('Time point');
ylabel('Cell Spread Area (# pixels)');