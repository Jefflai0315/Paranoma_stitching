function [images] = loadImages(index)
    path = strcat('..\Images\Set', int2str(index) , '\');
    files = dir(path);
    files = files(1:end);

    N = numel(files);
    images = {};
    cnt = 1;
    for i = 1:N
        if files(i).name(1) ~= '.'
        im = imread(strcat(path,files(i).name));
        im = image2cylindrical(im, 500, 0.0, 0.0, 0.0);
        images{cnt} = double(imresize(im, [480, 640]))/255;
        imshow(images{cnt});
        %drawnow;
        cnt = cnt + 1;
        end
    end
end