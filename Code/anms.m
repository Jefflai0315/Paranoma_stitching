
function [x, y, rmax] = anms(corners, max_pts)
    
    tic
    H = size(corners, 1);
    W = size(corners, 2);
    r_mat = zeros(H, W);
    
    
    for i = 1:H
    for j = 1:W
        for r = 1:min(H,W)
            if corners(i, j) == 0 
                r_mat(i, j) = 1;
                break;
            end
            if  any(corners(max(1,i-r):min(H,i+r), max(1,j-r)) > corners(i,j)) > 0 | ...
                any(corners(max(1,i-r):min(H,i+r), min(W,j+r)) > corners(i,j)) > 0 | ...
                any(corners(max(1,i-r), max(1,j-r):min(W,j+r)) > corners(i,j)) > 0 | ...
                any(corners(min(H,i+r), max(1,j-r):min(W,j+r)) > corners(i,j)) > 0
                r_mat(i, j) = r;
                break;
            end
        end
    end
    end
    
    [x, y] = meshgrid(1:W, 1:H);
  
    mat = [x(:) y(:) r_mat(:)];
    [~, idx] = sort(mat(:,3), 'descend');
    mat_sorted = mat(idx, :);
    x = mat_sorted(1:max_pts,1);
    y = mat_sorted(1:max_pts,2);
    rmax = mat_sorted(max_pts, 3);
    toc
    end