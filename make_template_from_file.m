function [template,selected] = make_template_from_file(fn, ch, threshold,to_save)
    if(nargin<1)
        fn = [];
    end
    if(nargin<2)
        ch = -1;
    end
    if(nargin<3)
        threshold = [];
    end
    if(nargin<4)
        to_save = true;
    end
   
    
    if(isempty(fn))
        [filename, pathname] = uigetfile('*.tif','Select a file to open');
        if(isequal(0,filename) || isequal(0,pathname))
            template = [];
            return
        else
            fn = fullfile(pathname,filename);
        end
    end
    
    
    [pathstr,filename,~] = fileparts(fn);
    dirname = fullfile(pathstr,'template');
    if(~java.io.File(dirname).isDirectory())
        mkdir(dirname);
    end
    fn_template_tif = fullfile(dirname,[filename '_avg.tif']);
    fn_template_mat = fullfile(dirname,[filename '_avg.mat']);
    
    [stack,info] = read_tiff(fn,ch);
    selected = cell(size(stack,4),1);
    for i = 1:size(stack,4)
        [template(:,:,i),selected{i}] = make_template(stack(:,:,:,i),[],[],threshold);
    end
    if(to_save)
        write_tiff(fn_template_tif,template,info);
        save(fn_template_mat,'template','selected','fn');
    end
end