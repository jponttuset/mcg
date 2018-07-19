function im_over = overlay_contour(image, partition, color, thickness)

if nargin<3
    color = [255, 255, 255];
end
if nargin<4
    thickness=2;
end

if (size(partition,1)==size(image,1)) && (size(partition,2)==size(image,2))
    bmap = seg2bmap(partition);
elseif (size(partition,1)==2*size(image,1)+1) && (size(partition,2)==2*size(image,2)+1)
    bmap = (partition(2:2:end,3:2:end) + partition(3:2:end,2:2:end))>0;
else
    error('Image and contour not compatible')
end

se = strel('square',thickness);
bmap = imerode(logical(1-bmap), se);
image = im2double(image);

if size(image, 3)==3  % Three channels
    im_over(:,:,1) = image(:,:,1).*bmap + (1-bmap)*color(1);
    im_over(:,:,2) = image(:,:,2).*bmap + (1-bmap)*color(2);
    im_over(:,:,3) = image(:,:,3).*bmap + (1-bmap)*color(3);
else
    im_over(:,:,1) = image(:,:,1).*bmap + (1-bmap)*color(1);
end


