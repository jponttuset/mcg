function bbox = mask2box( mask )
    tmp = regionprops(double(mask),'BoundingBox'); % Double to force a single bbox
    if isempty(tmp)
        bbox = [1 1 2 2];
    else
        bbox(1) = tmp.BoundingBox(2)+0.5;
        bbox(2) = tmp.BoundingBox(1)+0.5;
        bbox(3) = tmp.BoundingBox(2)+tmp.BoundingBox(4)-0.5;
        bbox(4) = tmp.BoundingBox(1)+tmp.BoundingBox(3)-0.5;
    end
end

