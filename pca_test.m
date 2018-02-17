clear;
num_cell = 17;
cell_coordinates = cell(num_cell);
num_points = zeros(1, num_cell );

%determine number of points to keep
for c = 1 : num_cell
    filename = ['SUM_outline_cell_' num2str(c) '.tif'];
    image = imread(filename);
    image = bwlabel(image) ; 
    [row, col] = find(image == 1);
    num_points(1, c) = size(row, 1);
end
num_sample = min(  num_points );

for iter = 1 : 1
        for k = 1 : num_cell
            for c = 1 : num_cell
                filename = ['SUM_outline_cell_' num2str(c) '.tif'];
                image = imread(filename);
                image = bwlabel(image) ; 
                [row, col] = find(image == 1);
                coor = [row col];
                randInd = randperm( size(coor, 1) );
                coor = coor( randInd(1:num_sample), :);
                
                if c == k
                    cell_coordinates{c} = coor;
                else
                    [d, Z, tr] = procrustes(cell_coordinates{k}, coor, 'scaling', false);
                    cell_coordinates{c} = Z;
                end 

            end
            %{
            if k == num_cell
                next_index = 1;
            else
                next_index = k + 1;
            end
            [d, Z, tr] = procrustes(cell_coordinates{next_index}, cell_coordinates{k} , 'scaling', false);
            cell_coordinates{k} = Z;
            %}
    end
end
for c = 1 : 4
    coordinates = cell_coordinates{c};
    plot(coordinates(:, 1), coordinates(:, 2), 'b.');
    hold on;
end

%{
%perform PCA
data_matrix = zeros(num_cell,  2*num_sample);

for data = 1 : num_cell
    data_col = zeros(0,0);
    cell_points_matrix = cell_coordinates{data};
    for p = 1 : size(cell_points_matrix, 1);
        point = cell_points_matrix(p, :);
       data_col = [data_col point];
    end
    data_matrix(data, :) = data_col;
end
[coeff,score,latent,tsquared,explained] = pca(data_matrix, 'centered', false);
tp_1(1, 1:10) = 0;
tp_5(1, 1:7) = 1;
gscatter(score(:, 1), score(:, 2), [tp_1 tp_5]  );
explained
%}



