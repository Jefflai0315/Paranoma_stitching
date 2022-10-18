function [corners] = detectCorners (img)
    if size(img, 3) > 1
        img = rgb2gray(img);
    end
    corners = cornermetric(img, 'Harris');
end