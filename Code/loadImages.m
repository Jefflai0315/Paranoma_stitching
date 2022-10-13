function [images] = loadImages()
    path = '..\Images\Set3\';
    files = dir(path);
    files = files(1:end);

    N = numel(files);
    images = {};
    cnt = 1;
    for i = 1:N
        if files(i).name(1) ~= '.'
        im = imread(strcat(path,files(i).name));
        im = double(im)/255;
        images{cnt} = im;
        %imshow(im);
        %drawnow;
        cnt = cnt + 1;
        end
    end
end