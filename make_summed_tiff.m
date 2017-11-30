function processed = make_summed_tiff(save_dir,opt)
    if(nargin<2)
        opt = '';
    end
    
    fns = dir(fullfile(save_dir,'*_summary.mat'));
    if(isempty(fns))
        fprintf('no summary files in the folder %s\n',save_dir);
        return;
    end
    summed_c = cell(1,1,length(fns));
    summed_align_c = cell(1,1,length(fns));
    t = cell(length(fns),1);
%     heatmap = cell(1,1,length(fns));
    for i=1:length(fns)
        tmp=load(fullfile(save_dir,fns(i).name));
        summed_c{i} = tmp.summed;
        if(isfield(tmp,'summed_align'))
            summed_align_c{i} = tmp.summed_align;
        end
        if(isfield(tmp,'t'))
            t{i} = tmp.t;
        end
%         if(isfield(tmp,'heatmap'))
%             heatmap{i} = tmp.heatmap;
%         end
    end
    summed = cell2mat(summed_c);
    summed_align = cell2mat(summed_align_c);
    t = cell2mat(t);
%     heatmap = cell2mat(heatmap);
    
    tkns=regexp(fns(1).name,'([^/]*)_summary.mat','once','tokens');
    fn_root = tkns{1};
    ffn = fullfile(save_dir,'summed',sprintf('%s_summed_%d.tif',fn_root,tmp.n_sum));
    ffn_align = fullfile(save_dir,'summed',sprintf('%s_summed_align.tif',fn_root));
    ffn_t = fullfile(save_dir,'summed',sprintf('%s_summed_t.mat',fn_root));
%     ffn_heatmap = fullfile(save_dir,'summed',sprintf('%s_summed_heatmap.mat',fn_root));
    
    processed = exist(ffn,'file') & exist(ffn_align,'file');
    if(strcmp(opt,'-s'))
        return;
    end
    
    warning off;
    mkdir(fullfile(save_dir,'summed'));
    warning on;
    write_tiff(ffn,int16(summed));
    
    if(~isempty(summed_align))
        write_tiff(ffn_align,int16(summed_align));
    end
    if(~isempty(t))
        save(ffn_t,'t');
    end
%     if(~isempty(heatmap))
%         save(ffn_heatmap,'heatmap');
%     end
    write_tiff(ffn,int16(summed));
%     fclose(fopen(fullfile(save_dir,'summed','DONE'),'w'));
end
