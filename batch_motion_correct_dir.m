function batch_motion_correct_dir(data_dir_path,people_dir_path,align_ch,save_ch,opt)
    if(~exist('opt','var'))
        opt='';
    end
    if(~exist('align_ch','var'))
        align_ch=[];
    end
    if(~exist('save_ch','var'))
        save_ch=[];
    end
    
    L=Logger();
    
    L.newline('Initializing');
    
    if(~exists_file(people_dir_path))
        mkdir(people_dir_path);
    end
    
    ffn_target = [];
    if(exists_file(fullfile(data_dir_path,'average','*_AVG.tif')))
        files = dir(fullfile(data_dir_path,'average','*_AVG.tif'));
        if(length(files)>1)
            warning('More than 1 AVG file found.');
        end
        ffn_target = fullfile(data_dir_path,'average',files(1).name);
        L.newline('%s is used as a target.',ffn_target);    
    else
        warning('no target found. will be generated from the first file.');
    end
    
%     L.newline('Done. Copying directories.');
%     
%     dirs=fastdir(data_dir_path,'','d');
%     for i=1:length(dirs)
%         if(~exists_file(fullfile(people_dir_path,dirs{i})))
%             copyfile(fullfile(data_dir_path,dirs{i}),fullfile(people_dir_path,dirs{i}),'f'); 
%         end
%     end
   
    L.newline('Done. Queueing motion correcting images.');
    
    [~,ffn_list] = fastdir(data_dir_path,common_regexp('tiff_ext'));
    batch_motion_correct_queued(ffn_list,ffn_target, people_dir_path,align_ch,save_ch,[],[],opt);
    
    L.newline('Done.');
end

function b = exists_file(fn)
    if(strfind(fn,'*'))
        b = ~isempty(dir(fn));
    else
        b = java.io.File(fn).exists()>0;
    end
end
