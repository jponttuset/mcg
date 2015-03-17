function area = box_area( bbox )
    up    = bbox(1);
    left  = bbox(2);
    down  = bbox(3);
    right = bbox(4);

    area = (down-up+1)*(right-left+1);
end

