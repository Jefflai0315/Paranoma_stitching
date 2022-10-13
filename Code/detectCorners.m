function [corners] = detectCorners (img)
    i_grey = rgb2gray(img);
    corners= cornermetric(i_grey,'Harris');
end