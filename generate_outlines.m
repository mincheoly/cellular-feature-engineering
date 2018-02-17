function [ output ] = generate_outlines_SIP(num_tp)
for t = 1 : num_tp
    cd(['tp_' num2str(t)]);
    names = dir('**.tif');
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
        imwrite(blank*255, ['SUM_' filename]);
        
        %make outline
        B = bwboundaries(blank, 8);
        outline_points = B{1};
        blank = zeros(height,width);
        for p = 1 : size(outline_points, 1)
            row = outline_points(p, 1);
            col = outline_points(p, 2);
            blank(row, col) = 255;
        end
        imwrite(blank, ['SUM_outline_' filename]);
    end
    cd('..');
end