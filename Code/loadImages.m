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
        [h,w,~] =size(im);
        m = max(h,w);
        d = 1;
        if m > 1000
            while m > 1000
                m = m/1.5;
                d = d * 1.5;
            end
            h = h/d;
            w = w/d;
        end

        if m/h >1.5 
            h = h*1.3;
            disp('reshape')
        elseif m/w > 1.5
            w = w*1.3;
            disp('reshape')
        end

        im = imresize(im, [h,w]);
        im = image2cylindrical(im, 500, 0.0, 1.0, 2.0);
        images{cnt} = double(im)/255;
        images{cnt} = double(im)/255;
        imshow(images{cnt});
        cnt = cnt + 1;
        end
    end
end