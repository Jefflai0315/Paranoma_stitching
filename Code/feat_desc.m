function [descs] = feat_desc(img, x, y)
    tic
    desc_size = 64; 
    sigma = 0.5;
    H = size(img, 1);
    W = size(img, 2);
    N = numel(x);
    descs = zeros(64, N);
    for i = 1:N
        [xx, yy] = meshgrid(x(i)-desc_size/2+1:x(i)+desc_size/2, y(i)-desc_size/2+1:y(i)+desc_size/2);
        xx(xx<=0) = 1;
        xx(xx>W) = W;
        yy(yy<=0) = 1;
        yy(yy>H) = H;
        idx  = (xx(:)-1)*H+yy(:);
        feat = img(idx);
        feat = reshape(feat, [desc_size, desc_size]);
        %feat = imgaussfilt(feat, sigma);
        % F = fspecial('gaussian',0.5);
        % feat = imfilter(feat,F,'replicate'); 
        feat = imresize(feat, [8, 8]);
        feat = double(feat);
        feat = (feat(:) - mean(feat(:)))/std(feat(:));
        descs(:, i) = feat;
        end
    toc
    end