function iou = boxes_iou( bbox1, bbox2 )
    area1  = box_area(bbox1);
    area2  = box_area(bbox2);
    inters = boxes_intersection(bbox1, bbox2);
    union  = area1+area2-inters;
    
    assert(union>0)
    iou = inters/union;
end

