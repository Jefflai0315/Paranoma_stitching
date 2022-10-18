# Panorama Stitching
![Paranoma Stitching](https://github.com/Jefflai0315/Paranoma_stitching/blob/main/Images/result.jpg)

## Step 0 : Load the images
``` matlab 
images = loadImages(directory);
``` 
The function performs [cylindrical projection](https://www.mathworks.com/matlabcentral/fileexchange/96962-image-to-cylindrical-and-spherical-projection-warping) on the images. Then we convert the images to double and normalize them.

___
## Step 1 : Detect Corners
``` matlab
corners_i = detectCorners(img_i);
```
The function convert image to gray scale and use Harris corner detector to detect corners. [use of matlab's cornermetric()]

- corners_i => corner metric of input image

___
## Step 2 : Adaptive Non-Maximal Suppression (or ANMS)
``` matlab
[i_x, i_y,rmax] = anms(corners_i, 500);
```
This is a method to reduce the number of keypoints. It is based on the assumption that keypoints are more likely to be found in regions of high contrast. The algorithm find the top 500 keypoints with the highest contrast. The contrast is calculated by the difference between the intensity of a pixel and the average intensity of its 8 neighbors. The keypoints are sorted in descending order of contrast. 

- i_x => x coordinates of keypoints
- i_y => y coordinates of keypoints
- rmax => suppression radius used to get max_pts corners 

___
## Step 3 : Feature Descriptors
``` matlab
[i_descs] = feat_desc(img_i, i_x, i_y);
```
find the feature descriptors of the keypoints and by 64 pixels around the keypoints. The feature descriptors are 64 dimensional vectors.

- i_descs => a 500 x 64 feature descriptors were each row is the 64 pixel values around the corresponding keypoint.

___
## Step 4 : Find the best matches
``` matlab
[match] = feat_match(i_descs, b_descs); 
```
Find the best matches between the keypoints of the source image and the keypoints of the destination image. The best matches are the matches with the smallest distance between the feature descriptors of the keypoints. The distance is calculated by the Euclidean distance between the feature descriptors of the keypoints.

- match => a N x 1 matrix, where the i-th element is the index of the best match of the i-th keypoint of the source image in the destination image. If there is no match, the i-th element is 0.

___
## Step 5 : RANSAC to find Homography Matrix
``` matlab
[H,inlier_indices] = ransac_est_H(matched_i_x, matched_i_y, matched_b_x, matched_b_y,0.1);
```
Find the homography matrix between the source image and the destination image. The homography matrix is a 3x3 matrix that transforms the coordinates of a point in the source image to the coordinates of the same point in the destination image. The homography matrix is found by using RANSAC. RANSAC is an algorithm that finds the best model for a set of data. The algorithm randomly selects 4 points from the set of data and finds the model that fits the 4 points. 

- H => Homography matrix
- inlier_indices => indices of the inliers

___
## Step 6 : Stitch the images
``` matlab
img_b = blend(img_i,img_b,H);
```
Stitch the images by warping the source image to the destination image and blending the two images together. The blending is done by taking the average of the pixel values of the two images at each pixel location.

- img_b => the stitched image

___
## Step 7 : Panorama Stitching
Using the above steps, I stitched 3 images together to create a panorama. The resulted image from Set2 is shown above.

