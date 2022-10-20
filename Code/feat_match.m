function [match] = feat_match(i_descs, b_descs)
    tic
    ni = size(i_descs,2);
    nb = size(b_descs,2);
    match = zeros(ni, 1);
    kdtree = KDTreeSearcher(b_descs');
    for i = 1:size(i_descs,2)
        desc = i_descs(:, i);
        [idx D] = knnsearch(kdtree, desc', 'K', 2);
        nn_i = b_descs(:,idx(1));
        nn_b = b_descs(:,idx(2));
        if sum((desc - nn_i).^2)/sum((desc - nn_b).^2) < 0.4
            match(i) = idx(1);
        else
            match(i) = -1;
        end
    end
    toc
end