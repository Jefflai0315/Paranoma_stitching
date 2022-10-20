function [pano] = MyPanorama()

    %% YOUR CODE HERE.
    % Must load images from ../Images/Input/
    % input : dataset folder number
    images = loadImages(1);

    %% Detect Corners: identify corner points in your images. 
    % initiate loop to stitch images starting from the middle image
    step = 1;
    sign = 1;
    num = 1;

    % define img_b as the destination image
    mid = floor(length(images)/2)+1;
    img_b = images{mid}; 

    % define img_i as the source image
    while num < length(images)
        if sign == 1
        img_i = images{mid-step};

        else
        img_i = images{mid + step};
        step = step + 1;
        end

        % detect corners for both destination and source images
        corners_i = detectCorners(img_i);
        corners_b = detectCorners(img_b);
       


        %% ANMS: use the ANMS function to select 350 corner points from each image.
        [i_x, i_y,rmax] = anms(corners_i, 500);
        [b_x, b_y,rmax] = anms(corners_b, 500);

        %imshow(img_i); hold on;
        %scatter(i_x,i_y,2)

        
        %% Extract features: use the feature description function to extract features from the images
        [i_descs] = feat_desc(img_i, i_x, i_y);
        [b_descs] = feat_desc(img_b, b_x, b_y);

       

        %% Match Features: match features between images. 
        [match] = feat_match(i_descs, b_descs);
        matched_b_x= b_x(match(match ~=-1));
        matched_b_y = b_y(match(match ~=-1));
        matched_i_x= i_x(match~=-1);
        matched_i_y = i_y(match~=-1);
        %hImage = showMatchedFeatures(img_i, img_b, [matched_i_x,matched_i_y], [matched_b_x,matched_b_y], 'montage')
        
        %imshow(img_i); hold on;
        %scatter(matched_i_x,matched_i_y,2)

        %% Estimate Homographies: estimate homographies between images. 
        [H,inliers_ind] = ransac_est_H(matched_i_x, matched_i_y, matched_b_x, matched_b_y,15);
        
        % show inliers and display the matched image points
        matched_b_x= matched_b_x(inliers_ind);
        matched_b_y = matched_b_y(inliers_ind);
        matched_i_x= matched_i_x(inliers_ind);
        matched_i_y = matched_i_y(inliers_ind);
        hImage = showMatchedFeatures(img_i, img_b, [matched_i_x,matched_i_y], [matched_b_x,matched_b_y], 'montage');
        if length(inliers_ind) < 5
            disp('not enough inliers')
            disp(inliers_ind)
            disp('Stitching fail, try again')
            break
        end

        %% Blend Images: blend images together to create a panorama.
        img_b = blend(img_i,img_b,H);
        imshow(img_b)


        sign = mod((sign + 1),2);
        num = num + 1;
    end

    %%  Finished panorama.
    imshow(img_b)
    sprintf('Finished!')
    pano = img_b;

end
