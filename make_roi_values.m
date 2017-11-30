function make_roi_values(save_path)
    if(iscell(save_path))
        for i=1:length(save_path)
            try
                make_roi_values(save_path{i});
            catch e
                disp(e)
                disp(e.stack);
            end
        end
        return;
    end
    
    fns = dir(fullfile(save_path,'*_roi.mat'));
    roi_values = cell(length(fns),1);
    frame_tag = cell(length(fns),1);
    for i=1:length(fns)
        fdata_roi=load(fullfile(save_path,fns(i).name));
        roi_values{i}=fdata_roi.roi_values;
        frame_tag{i}=fdata_roi.frame_tag;
    end
    roi_values = cell2mat(roi_values);
    frame_tag = cell2mat(frame_tag);
    roi_mask_2d = fdata_roi.roi_mask_2d;
    roi_ffn = fdata_roi.roi_ffn;
    save(fullfile(save_path,'roi_values.mat'), 'roi_values','frame_tag','roi_mask_2d','roi_ffn');
    
    roi_file = fullfile(save_path,'roi_values.mat');
    dfof_file = fullfile(save_path,'dfof.mat');
    
    make_dfof(roi_file,dfof_file);
end

%%


