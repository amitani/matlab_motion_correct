function done = motion_correct(fn,target,save_path,align_ch,save_ch,n_sum,n_sum_align,n_ch,to_use_mex,ffn_ROI)
    % save_path should be made beforehand, and all the arguments should be given.
    % if target is empty, do nothing but return whether it is done.
    if(nargin<8)
        n_ch = [];
    end
    
    v = version('-release');vn = str2double(v(1:4));
    to_use_mex_default = vn>=2012 && 3==exist('mexBilinearRegistrator','file') && 3==exist('mexBilinearShift','file');
    if(nargin<9 || isempty(to_use_mex))
        to_use_mex = to_use_mex_default;
    elseif(to_use_mex && ~to_use_mex_default)
        warning('mex is not configured yet. please compile mexBilinearRegistrator and mexBilinearShift.');
        to_use_mex = false;
    end
    
    threshold = [];
    replacement = [];
    
    [pathstr,fn_root]=fileparts(fn);
    params_mc = load_mc_settings_from_xml(pathstr);
    if(~isempty(params_mc))
        threshold = params_mc.threshold;
        replacement = params_mc.replacement;
    end
    
    fn_corrected_tif = fullfile(save_path,[fn_root '_corrected.tif']);
    fn_avg_tif = fullfile(save_path,[fn_root '_AVG.tif']);
    fn_summary_mat = fullfile(save_path,[fn_root '_summary.mat']);
    fn_roi_mat = fullfile(save_path,[fn_root '_roi.mat']);
    
    if(isempty(target))
        done = (java.io.File(fn_corrected_tif).exists() ...
               & java.io.File(fn_summary_mat).exists());...
%                | ...
%                (java.io.File(fn_roi_mat).exists() ...
%                & java.io.File(fn_summary_mat).exists())...
%                ;
        if(done)
            try
                tmp=load(fn_summary_mat);
            catch % file corrupted
                done = false;
            end
        end
        return;
    end
    
    L = Logger();
    
    if(ischar(target))
        L.newline('Reading target image. %s',target);
    else
        L.newline('Reading target image.');
    end
    target=parse_image_input(target,align_ch);
    
    L.newline('Done. Reading source image. %s', fn);
    
    [image_stack, info, frame_tag] = read_tiff(fn,[align_ch save_ch],n_ch);
    image_stack_align = image_stack(:,:,:,1);
    image_stack_save = image_stack(:,:,:,2);
    if(~isempty(threshold)&&~isnan(threshold))
        for i=1:size(image_stack_align,3)
            tmp=image_stack_align(:,:,i);
            if(~isempty(replacement)&&~isnan(replacement))
                tmp(tmp<threshold)=replacement;
            else
                tmp(tmp<threshold)=nanmean(tmp(tmp<threshold));
            end
            image_stack_align(:,:,i)=tmp;
        end
        for i=1:size(image_stack_save,3)
            tmp=image_stack_save(:,:,i);
            if(~isempty(replacement)&&~isnan(replacement))
                tmp(tmp<threshold)=replacement;
            else
                tmp(tmp<threshold)=nanmean(tmp(tmp<threshold));
            end
            image_stack_save(:,:,i)=tmp;
        end
    end
    
    t0 = [];
    running_template = [];
    
    if(isempty(params_mc))
        if(to_use_mex)
            target = int16(target);
            image_stack_align = int16(image_stack_align);
            image_stack_save = int16(image_stack_save);
        end
        L.newline('Done. Motion correcting.');
        if(to_use_mex)
            margin = ceil(size(image_stack_align,1)/8);
            t = mexBilinearRegistrator(target,image_stack_align,margin,3,2,1,0,0);
            method = 'interpolate_mex';
        else
            ir = BilinearPyramidImageRegistrator(target,0.75,3);
            t = zeros(size(image_stack_align,3),2);
            for j = 1:size(image_stack_align,3);
                t(j,:)=ir.register(double(image_stack_align(:,:,j)));
            end
            method = 'interpolate';
        end
        heatmap = [];
    else
        L.newline('Done. Motion correcting.');
        
%         t_target = round(cvMotionCorrect(target,mean(image_stack_align,3),'margin',96));
%         tmp_target = mexBilinearShift(target,t_target);
%         [t, heatmap] = cvMotionCorrect(image_stack_align, tmp_target,'factor',params_mc.factor,'marginh',params_mc.marginh, ...
%             'marginw',params_mc.marginw,'sigma_smoothing',params_mc.sigmaSmoothing,'sigma_normalization',params_mc.sigmaNormalization, ...
%             'normalization_offset',params_mc.normalizationOffset);
%         t=bsxfun(@minus,t,t_target);
%         method = 'cv_avg';
        if(params_mc.margin_running>0)
            [running_template, dt, ~, heatmap] = make_stable_average(image_stack_align,'factor',params_mc.factor,'marginh',params_mc.marginh, ...
                'marginw',params_mc.marginw,'sigma_smoothing',params_mc.sigmaSmoothing,'sigma_normalization',params_mc.sigmaNormalization, ...
                'normalization_offset',params_mc.normalizationOffset);
            [t0] = cvMotionCorrect(running_template, target,'factor',params_mc.factor,'marginh',params_mc.margin_running, ...
                'marginw',params_mc.margin_running,'sigma_smoothing',params_mc.sigmaSmoothing,'sigma_normalization',params_mc.sigmaNormalization, ...
                'normalization_offset',params_mc.normalizationOffset);
            t = bsxfun(@plus,t0,dt);
            method = 'cv_rt';
        else
            [t, heatmap] = cvMotionCorrect(image_stack_align, target,'factor',params_mc.factor,'marginh',params_mc.marginh, ...
                'marginw',params_mc.marginw,'sigma_smoothing',params_mc.sigmaSmoothing,'sigma_normalization',params_mc.sigmaNormalization, ...
                'normalization_offset',params_mc.normalizationOffset);
            method = 'cv';
        end
    end
    
    L.newline('Done. Shifting signal ch.');
    if(to_use_mex)
        corrected = mexBilinearShift(image_stack_save,t);
    else
        corrected = zeros(size(image_stack_save),'single');
        for j = 1:size(image_stack_save,3);
            corrected(:,:,j)=BilinearPyramidImageRegistrator.shift(...
                image_stack_save(:,:,j),t(j,:));
        end
    end
    
    L.newline('Done. Saving corrected files.');
    
    if(exist('ffn_ROI','var')&&~isempty(ffn_ROI)&&exist(ffn_ROI,'file'))
        try
            roi_ffn=ffn_ROI;
            roi_mask_2d =  sparse(read_roi(roi_ffn,512,512,2,32));
            data_2d = reshape(corrected,512*512,size(corrected,3));
            roi_values = double(data_2d)'*roi_mask_2d;
            save(fn_roi_mat,'roi_values','frame_tag','roi_mask_2d','roi_ffn');
        catch
            write_tiff(fn_corrected_tif,int16(corrected),info);
        end
    else
        write_tiff(fn_corrected_tif,int16(corrected),info);
    end
    
    
    
    if(n_sum_align>0)
        L.newline('Done. Shifting align ch.');
        if(align_ch == save_ch)
            corrected_align = corrected;
        else
            if(to_use_mex)
                corrected_align =  mexBilinearShift(image_stack_align,t);
            else
                corrected_align = zeros(size(image_stack_align),'single');
                for j = 1:size(image_stack_align,3);
                    corrected_align(:,:,j)=BilinearPyramidImageRegistrator.shift(...
                        image_stack_align(:,:,j),t(j,:));
                end
            end
        end
        summed_align = cast(downsample_mean(corrected_align,n_sum_align,3),class(image_stack_align));
    else
        summed_align = [];
    end
    
    L.newline('Done. Saving data.');
    
    info_first = info(1);
    if(n_sum>0)
        summed = cast(downsample_mean(corrected,n_sum,3),class(image_stack_save));
    else
        summed = [];
    end
    
    save(fn_summary_mat, '-v6',   'summed',...
                                  'summed_align',...
                                  'frame_tag',...
                                  'info_first',...
                                  't',...
                                  't0',...
                                  'running_template',...
                                  'target',...
                                  'method', ...
                                  'params_mc',...
                                  'align_ch',...
                                  'save_ch',...
                                  'n_sum',...
                                  'n_sum_align',...
                                  'heatmap');
    L.newline('Done.');
    
    
    done=true;
end

