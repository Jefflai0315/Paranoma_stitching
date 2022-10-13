% stitch images from BASE_IMG - 1 to 1 to img_b
path = '..\Images\Set1\'
img_b = imread('..\Images\Set1\1.jpg');
img_b = double(img_b)/255;
for i = [2:3]
    %i = mid + k
    img_i = imread(strcat(path , num2str(i) ,'.jpg'));
    img_i = double(img_i)/255;
    img_b = stitch(img_i, img_b);
    %j = mid - i
    %img_i = imread(strcat(path , num2str(i) ,'.jpg'));
    %img_i = double(img_i)/255;
    %img_b = stitch(img_i, img_b);
    end
    
imshow(img_b)
    



% generate distance to border map
function [img_dist] = dist2border(img)
    if size(img,3) > 1
        img = rgb2gray(img);
    end
    img_dist = (img == 0);
    img_dist(1:size(img,1), 1) = 1;
    img_dist(1:size(img,1), size(img,2)) = 1;
    img_dist(1, 1:size(img,2)) = 1;
    img_dist(size(img,1), 1:size(img,2)) = 1;
    img_dist = bwdist(img_dist, 'chessboard');
end




function [img_b] = stitch(img_i, img_b)
hei_i = size(img_i,1);
wid_i = size(img_i,2);
hei_b = size(img_b,1);
wid_b = size(img_b,2);
I_grey = rgb2gray(img_i);
C = cornermetric(I_grey,'Harris');
I_2_grey = rgb2gray(img_b);
C_2 = cornermetric(I_2_grey,'Harris');
% imagesc(C);
%disp(size(I_grey))
[N_best_x, N_best_y,rmax] =anms(C,500);
 
%imshow(img_i); hold on;
%scatter(N_best_x, N_best_y,1)

[descs] = feat_desc(img_i,N_best_x, N_best_y);


[N_best_x_2, N_best_y_2,rmax_2] =anms(C_2, 400);
[descs_2] = feat_desc(img_b,N_best_x_2, N_best_y_2);
disp(N_best_x_2)
[match] = feat_match(descs, descs_2);
%imshow(I_2); hold on;
%scatter(N_best_x_2, N_best_y_2,1)

% get index of match that is not -1
match_2 = match(match(:,1)~=-1);
 MatchPoint_2_x = N_best_x_2(match_2);
 MatchPoint_2_y = N_best_y_2(match_2);

 
 matchedPoint_2 = [MatchPoint_2_x, MatchPoint_2_y];

 %get element of match that is not -1
 MatchPoint_x = N_best_x((match(:,1)~=-1));
 MatchPoint_y = N_best_y((match(:,1)~=-1));
 matchedPoint = [MatchPoint_x, MatchPoint_y];



%hImage = showMatchedFeatures(I, I_2, matchedPoint, matchedPoint_2, 'montage')

%H=est_homography(MatchPoint_x, MatchPoint_y,MatchPoint_2_x, MatchPoint_2_y)

[H,inlier_indices] = ransac_est_H(MatchPoint_x, MatchPoint_y,MatchPoint_2_x, MatchPoint_2_y, 0.1);
% compute d2b
img_i_dist = dist2border(img_i);
img_b_dist = dist2border(img_b);

% mapped coordinates of upperleft, upperright, bottomleft, bottomright
% for img_i
ul = H*[1 1 1]'; ul = ul/ul(end);
ur = H*[wid_i, 1, 1]'; ur = ur/ur(end);
bl = H*[1, hei_i, 1]'; bl = bl/bl(end);
br = H*[wid_i, hei_i, 1]'; br = br/br(end);
tic

% find out how much padding we need to make
pad_up = 0; % update pad_up and pad_left inorder to do an offset mapping 
pad_left = 0;
pad_down = 0;
pad_right = 0;
if max(br(1),ur(1)) > wid_b
    pad_right = round(max(br(1),ur(1))-wid_b+30);
    img_b = padarray(img_b, [0, pad_right], 'post');
end
if max(br(2), bl(2)) > hei_b
    pad_down = round(max(br(2), bl(2))-hei_b+30);
    img_b = padarray(img_b, [pad_down, 0], 'post');
end
if min(ul(1), bl(1)) <= 0 
    pad_left = round(-min(ul(1), bl(1))+30);
    img_b = padarray(img_b, [0, pad_left], 'pre');
end
if min(ul(2), ur(2)) <= 0
    pad_up = round(-min(ul(2), ur(2)) + 30);
    img_b = padarray(img_b, [pad_up, 0], 'pre');
end
H_inv = inv(H);


% - Mapping coordinates from img_b to img_i to retrieve pixels
% - Implemented distance to border blending
% - Vecterized

[y_b, x_b] = meshgrid(round(pad_up+min(ul(2), ur(2))):round(pad_up+max(bl(2), br(2))), ...
    round(pad_left+min(ul(1), bl(1))):round(pad_left+max(br(1),ur(1))));
y_b = y_b(:); x_b = x_b(:);
xy = H_inv*[x_b - pad_left, y_b - pad_up, ones(size(x_b,1),1)]';
x_i = int64(xy(1,:)'./xy(3,:)'); y_i = int64(xy(2,:)'./xy(3,:)');

% Blend img_b and img_i pixels according to dist to boundary
% Only the coordinates that are possible to map to img_i are considerred.
indices = x_i > 0 & x_i <= size(img_i, 2) & y_i > 0 & y_i <= size(img_i, 1) & y_b-pad_up > 0 & y_b - pad_up <= size(img_b_dist,1) & x_b - pad_left > 0 & x_b - pad_left <= size(img_b_dist,2);
idx_i = (x_i(indices)-1)*size(img_i_dist,1) + y_i(indices);
idx_b = (x_b(indices)-pad_left-1)*size(img_b_dist,1) + y_b(indices)-pad_up;
p = img_i_dist(idx_i)./(img_i_dist(idx_i) + img_b_dist(idx_b));
p(isnan(p)) = 0;
% map rgb channels
img_b((x_b(indices)-1)*size(img_b,1)+(y_b(indices))) = p.*img_i((x_i(indices)-1)*size(img_i,1) + (y_i(indices))) + (1-p).*img_b((x_b(indices)-1)*size(img_b,1) +(y_b(indices)));
img_b((x_b(indices)-1)*size(img_b,1)+y_b(indices) + size(img_b,1)*size(img_b,2) ) = p.*img_i((x_i(indices)-1)*size(img_i,1) + y_i(indices) + size(img_i,1)*size(img_i,2)) + ... 
    (1-p).*img_b((x_b(indices)-1)*size(img_b,1) + y_b(indices) + size(img_b,1)*size(img_b,2));
img_b((x_b(indices)-1)*size(img_b,1)+y_b(indices) + size(img_b,1)*size(img_b,2)*2 ) = p.*img_i((x_i(indices)-1)*size(img_i,1) + y_i(indices) + size(img_i,1)*size(img_i,2)*2) + ... 
    (1-p).*img_b((x_b(indices)-1)*size(img_b,1) + y_b(indices) + size(img_b,1)*size(img_b,2)*2);

% if it goes beyond border of img_b, just copy back the pixels from img_i
indices = x_i > 0 & x_i <= size(img_i, 2) & y_i > 0 & y_i <= size(img_i, 1) & (y_b-pad_up <= 0 | y_b - pad_up > size(img_b_dist,1) | x_b - pad_left <= 0 | x_b - pad_left > size(img_b_dist,2));
% rgb channels
img_b((x_b(indices)-1)*size(img_b,1)+y_b(indices)) = img_i((x_i(indices)-1)*size(img_i,1) + y_i(indices));
img_b((x_b(indices)-1)*size(img_b,1)+y_b(indices) + size(img_b,1)*size(img_b,2) ) = img_i((x_i(indices)-1)*size(img_i,1) + y_i(indices) + size(img_i,1)*size(img_i,2));
img_b((x_b(indices)-1)*size(img_b,1)+y_b(indices) + size(img_b,1)*size(img_b,2)*2 ) = img_i((x_i(indices)-1)*size(img_i,1) + y_i(indices) + size(img_i,1)*size(img_i,2)*2);

toc
end


    