function [ output ] = draw_spread_area_boxplots(mask_filename_3d_1, mask_filename_3d_2, T, Z)
%for testing stack 
% T = 53
%Z = 54
%save values
info_mask_1 = imfinfo(mask_filename_3d_1);
info_mask_2 = imfinfo(mask_filename_3d_2);
width = info_mask_1(1).Width;
height = info_mask_1(1).Height;
fprintf('width: %d \n', width);
fprintf('height:%d \n', height);
fprintf('Num images: %d \n', size(info_mask_1, 1) + size(info_mask_2, 1) );
spread_area_cell = cell(1, T);
max_num_cell = -1;

for t = 1 : T %for every time point in T
    %list of cell spread area for this time point
    
    %build the 3D matrix
    mask_3d = zeros(height, width, Z);
    
    if t <= 27
        for z = 1 : Z
            frame_index = (t - 1)*Z + z;
            mask_3d(:,:,z) = (imread(mask_filename_3d_1, frame_index))/255; 
        end
    else
        for z = 1 : Z
            frame_index = (t - 1 - 27)*Z + z;
            mask_3d(:,:,z) = (imread(mask_filename_3d_2, frame_index))/255; 
        end
    end
    
    fprintf('Time point %d 3d matrix built \n', t);
    
    %clear border
    mask_3d = imclearborder(mask_3d, 26);
    fprintf('Time point %d 3d border cleared \n', t);
    
    %bwlabel this shit, %update numcell
    [L, NUM_CELLS] = bwlabeln(mask_3d, 26);
    fprintf('Time point %d 3d labeled \n', t);
    if NUM_CELLS > max_num_cell
        max_num_cell = NUM_CELLS;
    end
    tp_list = zeros(NUM_CELLS, 1);
    
    %make mini MIPs
    for c = 1 : NUM_CELLS
        [x, y, z] = ind2sub(size(L), find(L == c) );
        coordinates = [x y z];
        blank_2d = zeros(height, width);
        for p = 1 : size(coordinates, 1)
            point = coordinates(p, :);
            row = point(1);
            col = point(2);
            if blank_2d(row, col) == 0
                blank_2d(row, col) = 1;
            end
        end
        cell_spread_area = sum(sum(blank_2d));
        %cell_volume = size(coordinates, 1);
        
        %add to this time point list
        tp_list(c) = cell_spread_area;
    end
    spread_area_cell{t} = tp_list;
end

%post processing, add NaNs
boxplot_matrix = zeros(max_num_cell, T);
disp('all data acquired');

for t = 1 : T
    this_tp = spread_area_cell{t};
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

disp('Done post processing');
boxplot(boxplot_matrix);
end

