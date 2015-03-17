function show_per_class_table( soa, soa_ids, res_id, measure )

% Pascal classes names
classes={'aeroplane', 'bicycle'  , 'bird'       , 'boat'       ,...
         'bottle'   , 'bus'      , 'car'        , 'cat'        ,...
         'chair'    , 'cow'      , 'diningtable', 'dog'        ,...
         'horse'    , 'motorbike', 'person'     , 'pottedplant',...
         'sheep'    , 'sofa'     , 'train'      , 'tvmonitor'  };

% Allocate
all_res = zeros(length(soa_ids),length(classes)+1);
ncands = zeros(length(res_id),1);

% Fill
for ii=1:length(soa_ids)
    ncands(ii) = soa.(soa_ids{ii}).mean_n_masks(res_id(ii));
    for kk=1:length(classes)
        if strcmp(measure,'jaccard_object')
            res = soa.(soa_ids{ii}).per_class_results{kk}.meanmax;
        else
            res = soa.(soa_ids{ii}).per_class_results{kk}.global_J;
        end
        all_res(ii,kk) = res(res_id(ii));
    end
    res = soa.(soa_ids{ii}).(measure);
    all_res(ii,end) = res(res_id(ii));
end

% Get the maximums to set in boldface
[~,max_ids] = max(all_res,[],1);
disp(['MCG is the best in ' num2str(sum(max_ids(1:end-1)==1)) ' categories'])

% Show header
to_disp = '    Method &   NCands & ';
for kk=1:length(classes)
    to_disp = [to_disp sprintf('%14s',classes{kk}) ' & ']; %#ok<AGROW>
end
to_disp = [to_disp '        Global \\'];
disp(to_disp)

% Show table
for ii=1:length(soa_ids)
    curr_n_reg = soa.(soa_ids{ii}).mean_n_masks(res_id(ii));
    to_disp = [sprintf('%10s', soa_ids{ii}) ' & ' sprintf('%4s%d',' ', round(curr_n_reg)) ' & '];
    for kk=1:length(classes)
        if (ii==max_ids(kk))
            to_disp = [to_disp sprintf('%13s',['\textbf{' sprintf('%2.1f',100*all_res(ii,kk))]) '} & ']; %#ok<AGROW>
        else
            to_disp = [to_disp sprintf('%13s',sprintf('%2.1f',100*all_res(ii,kk))) '  & ']; %#ok<AGROW>
        end
    end
    if (ii==max_ids(end))
        to_disp = [to_disp sprintf('%13s',['\textbf{' sprintf('%2.1f',100*all_res(ii,end))]) '} \\ ']; %#ok<AGROW>
    else
        to_disp = [to_disp sprintf('%13s',sprintf('%2.1f',100*all_res(ii,end))) '  \\']; %#ok<AGROW>
    end
    disp(to_disp)
end

end

