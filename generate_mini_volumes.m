function [ output ] = generate_mini_volumes(mask_filename_3d, Z, T)

infoA = imfinfo(mask_filename_3d);
width = infoA(1).Width;
height = infoA(1).Height;

for t = 1 : T %for every time point in T    
    %build the 3D matrix for that tp
    mask_3d = zeros(height, width, Z);
    for z = 1 : Z
        frame_index = (t - 1)*Z + z;
        mask_3d(:,:,z) = (imread(mask_filename_3d, frame_index))/255; 
    end    
    fprintf('Time point %d 3d matrix built \n', t);
   
    %clear border
    mask_3d = imclearborder(mask_3d, 26);
    fprintf('Time point %d 3d border cleared \n', t);
    
    %bwlabel this shit, 
    [L, NUM_CELLS] = bwlabeln(mask_3d, 26);
    fprintf('Time point %d 3d labeled \n', t);
    
    %make a directory for this timepoint
    mkdir(['tp_' num2str(t)]);
    cd(['tp_' num2str(t)]);
    
    cell_count = 0;
    %make mini volumes
    for c = 1 : NUM_CELLS
        [row, col, h] = ind2sub(size(L), find(L == c) );
        if size(row, 1) > 1000
            cell_count = cell_count + 1;
            
            %blank 3d matrix
            mini_rows = max(row) - min(row) + 1;
            mini_cols = max(col) - min(col) + 1;
            mini_h = max(h) - min(h) + 1;
            blank_3d = zeros(mini_rows, mini_cols, mini_h);

            %get adjusted coordinates
            row = row - min(row) + 1;
            col = col - min(col) + 1;
            h = h - min(h) + 1;
            coordinates = [row col h];
            for p = 1 : size(coordinates, 1)
                blank_3d(row(p), col(p), h(p) ) = 255;
            end

            for z = 1 : mini_h
                if z == 1
                    imwrite(blank_3d(:,:,z), ['cell_' num2str(cell_count) '.tif'])
                else
                    imwrite(blank_3d(:,:,z), ['cell_' num2str(cell_count) '.tif'], 'writemode', 'append')
                end
            end
        end
    end
    cd('..');
    
end    
end

