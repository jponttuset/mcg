function im_over = mask_image(image, mask, transparency)

if nargin==2
    transparency = [0.5 0.9 0.5];
end
if length(transparency)==1
    transparency = [transparency transparency transparency];
end

if (size(mask,1)~=size(image,1)) || (size(mask,2)~=size(image,2))
    error('Image and contour not compatible')
end

image = im2double(image);

if size(image, 3)==3  % Three channels
    im_over(:,:,1) = image(:,:,1).*mask + (1-mask).*(image(:,:,1)+transparency(1)*(1-image(:,:,1)));
    im_over(:,:,2) = image(:,:,2).*mask + (1-mask).*(image(:,:,2)+transparency(2)*(1-image(:,:,2)));
    im_over(:,:,3) = image(:,:,3).*mask + (1-mask).*(image(:,:,3)+transparency(3)*(1-image(:,:,3)));
else
	error('Not implemented')
end


