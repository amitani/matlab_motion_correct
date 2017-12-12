function batch_motion_correct_queued(fn_list,target,save_path,align_ch,save_ch, n_sum, n_sum_align,opt,to_queue,ffn_ROI)
    if(isempty(fn_list))
        warning('No files selected.')
        return;
    end
    if(ischar(fn_list))
        if(isdir(fn_list))
            [~, fn_list] = fastdir(fn_list,common_regexp('tiff_ext'));
        else
            fn_list = {fn_list};
        end
    end
    if(nargin<2)
        target = [];
    end
    if(nargin<3||isempty(save_path))
        warning('Save path is not set! Doing nothing.')
        return;
    end
    
    if(nargin<4 || isempty(align_ch))
        align_ch = -1; % last channel
    end
    if(nargin<5 || isempty(save_ch))
        save_ch = 1;
    end
    
    if(nargin<6||isempty(n_sum))
        n_sum = 50;
    end
    
    if(nargin<7||isempty(n_sum_align))
        n_sum_align = inf;
    end
    if(nargin<8||isempty(opt))
        opt='';
    end
    if(nargin<9||isempty(to_queue))
        to_queue = any(1==strfind(mfilename('fullpath'),'/usr/local/lab/People/Aki/ForLabMembers/'));
    end
    if(nargin<10||isempty(ffn_ROI))
        ffn_ROI = [];
    end
    
    
    L = Logger;
    
    [~,fn_root,~] = fileparts(fn_list{1});
    target_save_path=fullfile(save_path,'target');
    target_fn = fullfile(target_save_path,[fn_root '_AVG.tif']);
    if(~exists_file(target_fn))
        if(isempty(target))
            L.newline('Making target from %s', fn_list{1});
            target =  make_template_from_file(fn_list{1},align_ch,[],false);
        end
    
        target=parse_image_input(target,align_ch);
        
        if(~exists_file(save_path))
            L.newline('Make save dir');
            mkdir(save_path);
        end
        if(~exists_file(target_save_path))
            mkdir(target_save_path);
        end
        write_tiff(target_fn,int16(target));
    end
    queued_job_ids = {}; 
    processed = false;
    L.newline('Queueing jobs');
    if(to_queue)
        for i = 1:length(fn_list)
            fn = fn_list{i};
            if(strcmp(opt,'f')||strcmp(opt,'force')||~motion_correct(fn,[],save_path,align_ch,save_ch, n_sum, n_sum_align))
                queued_job_ids{end+1}=queue_job('motion_correct',{fn,target_fn,save_path,align_ch,save_ch, n_sum, n_sum_align});
                processed = true;
            else
                disp('skipping because already motion corrected.');
            end
        end
    else
        to_process=false(length(fn_list),1);
        for i = 1:length(fn_list)
            fn = fn_list{i};
            if(strcmp(opt,'f')||strcmp(opt,'force')||~motion_correct(fn,[],save_path,align_ch,save_ch, n_sum, n_sum_align))
                to_process(i)=true;
            else
                disp('skipping because already motion corrected.');
            end
        end
        if(any(to_process))
            fn_list_to_compute=fn_list(to_process);
            if exist('gcp')
                if isempty(gcp('nocreate'))
                    parpool(2);
                end
            else
                try
                    matlabpool 2
                catch e
                    disp(e);
                end
            end
            parfor i=1:length(fn_list_to_compute)
%             for i=1:length(fn_list_to_compute)
                fn = fn_list_to_compute{i};
                motion_correct(fn,target_fn,save_path,align_ch,save_ch, n_sum, n_sum_align,[],[],ffn_ROI);
            end
        end
        processed = any(to_process);
    end
    if(processed || ~make_summed_tiff(save_path,'-s'))
        if(to_queue)
            queue_job('make_summed_tiff',{save_path},queued_job_ids);
        else
            make_summed_tiff(save_path);
        end
    end
    if(~isempty(ffn_ROI)&&(processed||~exist(fullfile(save_path,'roi_values.mat'),'file')))
        try
            make_roi_values(save_path);
        catch e
            disp(e);
        end
    end
    
    L.newline('done');
end

function b = exists_file(fn)
    b = java.io.File(fn).exists()>0;
end
