function make_dfof(roi_file,dfof_file)
    if(~exist(roi_file,'file') || exist(dfof_file,'file') && ~is_newer(roi_file,dfof_file))
        return;
    end
    disp(roi_file);
    rv_data = load(roi_file);

    BASELINE_PERCENTILE = 0.08;
    DFOF_LIST_LENGTH = 200;

    SGOLAY_K = 2;
    SGOLAY_F = 9;
    [~, g] = sgolay(SGOLAY_K,SGOLAY_F);
    FILTER_X = g(:,1);

    rv_bs = ordfilt2(conv2(rv_data.roi_values,FILTER_X,'same') ,BASELINE_PERCENTILE*DFOF_LIST_LENGTH,[ones(DFOF_LIST_LENGTH,1); zeros(DFOF_LIST_LENGTH-1,1)],'symmetric');

    bg = rv_data.roi_values(:,end)./rv_bs(:,end);
    dfof = bsxfun(@minus,rv_data.roi_values(:,1:end-1)./rv_bs(:,1:end-1),bg);
    frame_tag = rv_data.frame_tag;
    roi_mask_2d = rv_data.roi_mask_2d;
    save(dfof_file,'rv_bs','dfof','frame_tag','roi_mask_2d','bg');
end
%             
%             if(i==1)
%                 rv_bs2 = ordfilt2(rv_data.roi_values ,BASELINE_PERCENTILE*DFOF_LIST_LENGTH,[ones(DFOF_LIST_LENGTH,1); zeros(DFOF_LIST_LENGTH-1,1)],'symmetric');
%                 bg2 = rv_data.roi_values(:,end)./rv_bs2(:,end);
%                 dfof2 = bsxfun(@minus,rv_data.roi_values(:,1:end-1)./rv_bs2(:,1:end-1),bg2);
% 
%                 save(dfof_file,'dfof','dfof2','frame_tag','roi_mask_2d','bg');
%             end
%             save(dfof2_file,'rv_bs','rv_bs2');
%             toc;
            
%             OFFSET_COEFFICIENT = 0.9;
%             SMOOTHING_WINDOW = 7;
%         
%             offset = zeros(size(dfof_raw));
%             for k=1:size(dfof_raw,2)
%                 offset(2:end,k) = OFFSET_COEFFICIENT * movingstd(diff(dfof_raw(:,k)),199,'b');
%             end
%             dfof = dfof_raw - offset;
%             for k=1:size(dfof,2)
%                 dfof(:,k) = smooth(dfof(:,k),SMOOTHING_WINDOW);
%             end
            
%             save(fullfile(ffn_mouse,dfof_file),'OFFSET_COEFFICIENT','SMOOTHING_WINDOW','dfof','dfof_raw','offset','frame_tag','roi_mask_2d','bg','-v6');
