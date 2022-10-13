function [pano] = MyPanorama()

%% YOUR CODE HERE.
% Must load images from ../Images/Input/
images = loadImages();
%Detect Corners: identify corner points in your images. (You can just use Matlab’s cornermetric
%function for this part.)
mid = floor(length(images)/2)+1;
img_b = images{mid};

% img_i = images{1};
% img_b = images{2};
step = 1;
sign = 1;
num = 1;
% image
%1 2 3 4 5 6 7 8 
while num < length(images)

if sign == 1
img_i = images{mid-step};
else
img_i = images{mid + step};
step = step + 1;
end

% imshow(img_i)

corners_i = detectCorners(img_i);
corners_b = detectCorners(img_b);

% ANMS: use the ANMS function to select 500 corner points from each image.
[i_x, i_y,rmax] = anms(corners_i, 500);
[b_x, b_y,rmax] = anms(corners_b, 500);

% Extract features: use the feature description function to extract features from the images
[i_descs] = feat_desc(img_i, i_x, i_y);
[b_descs] = feat_desc(img_b, b_x, b_y);

% %Match Features: match features between images. (You can just use Matlab’s matchFeatures function
% %for this part.)
[match] = feat_match(i_descs, b_descs);
id_b = match(match(:,1)~=-1);
matched_b_x= b_x(id_b);
matched_b_y = b_y(id_b);
matched_i_x= i_x((match(:,1)~=-1));
matched_i_y = i_y((match(:,1)~=-1));
% hImage = showMatchedFeatures(img_i, img_b, matched_i, matched_b, 'montage')


% %Estimate Homographies: estimate homographies between images. (You can just use Matlab’s
% %estimateGeometricTransform function for this part.)
[H,inlier_indices] = ransac_est_H(matched_i_x, matched_i_y, matched_b_x, matched_b_y,0.1);

% matched_b_x= matched_b_x(inlier_indices);
% matched_b_y = matched_b_y(inlier_indices);
% matched_i_x= matched_i_x(inlier_indices);
% matched_i_y = matched_i_y(inlier_indices);
% hImage = showMatchedFeatures(img_i, img_b, [matched_i_x,matched_i_y], [matched_b_x,matched_b_y], 'montage')

% %Blend Images: blend images together to create a panorama. (You can just use Matlab’s imwarp
% %function for this part.)
img_b = blend(img_i,img_b,H);
% pano = blendImages(images, homographies);



sign = mod((sign + 1),2);
num = num + 1;
end
pano = img_b
imshow(pano)
% % Must return the finished panorama.
sprintf('Hi there!')

end
