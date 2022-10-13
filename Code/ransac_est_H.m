function [H, inliers_ind] = ransac_est_H(x1, y1, x2, y2, thresh)
    tic
    
    N = numel(x1);
    max_inliers = zeros(N, 1);
    H = eye(3);
    ssd = @(x, y) sum((x-y).^2);
    %inliers = zeros(N, 1);
    for t = 1:1000
    r_idx = randi([1, N], 4,1);
    inliers = zeros(N, 1);
    H_t = est_homography(x2(r_idx),y2(r_idx),x1(r_idx),y1(r_idx));
    % (x2, y2, 1)^T ~ H (x1, y1, 1)^T
    for i = 1:N
        t_xy = H_t*[x1(i), y1(i), 1]';
        t_xy = t_xy/t_xy(end);
        
        if ssd([x2(i), y2(i), 1]', t_xy) < thresh
            % inliers(i) =  inliers(i) + 1;
            inliers(i) =  1;
            
        end
    end
    if sum(inliers) > sum(max_inliers)
        max_inliers = inliers;
        H = H_t;
    end
    end
    % % if inliers value < N, value = 0 , else = 1
    % for i = 1:N
    %     if inliers(i)/1000 < thresh/1.5
    %         inliers(i) = 0;
    %     else
    %         inliers(i) = 1;
    %     end
    % end
    %inliers_ind = find(inliers);
    inliers_ind = find(max_inliers);

    %H = est_homography(x2(inliers_ind),y2(inliers_ind),x1(inliers_ind),y1(inliers_ind));
    toc
    end