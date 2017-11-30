function [stack,info,frame_tag] = read_tiff(fn, ch, n_ch, info_all)
    if(nargin<1)
        [filename, pathname]=uigetfile({'*.tiff;*.tif','Tiff Files(*.tiff, *.tif)'},'Select Tiff file');
        fn = fullfile(pathname,filename);
    end
    if(nargin<2)
        ch=1;
    end
    if(nargin<3)
        n_ch=[];
    end
    if(nargin<4)
        info_all=[];
    end
    
    if(iscell(fn))
        stack_c = cell(numel(fn),1);
        info_c = cell(numel(fn),1);
        frame_tag_c = cell(numel(fn),1);
        for i=1:numel(fn)
            if(nargout>2)
                [stack_c{i}, info_c{i}, frame_tag_c{i}] = read_tiff(fn{i}, ch, n_ch, info_all);
            else
                [stack_c{i}, info_c{i}] = read_tiff(fn{i}, ch, n_ch, info_all);
            end
        end
        stack = cat(3,stack_c{:});
        info = cat(1,info_c{:});
        frame_tag = cat(1,frame_tag_c{:});
        return;
    end
    
    temp_fn = tempname_if_on_network(fn);
    if(~isempty(temp_fn))
        copyfile(fn,temp_fn);
        file_to_read = temp_fn;
        file_to_delete = temp_fn;
    else
        file_to_read = fn;
        file_to_delete = '';
    end
    
    try
        if(isempty(info_all))
            info_all = imfinfo(file_to_read);
        end
        if(isempty(n_ch))
            n_ch = get_n_ch_from_info(info_all);
            if(isnan(n_ch))
                n_ch=1;
            end
        end
        frame_tag = get_frame_tag_from_info(info_all);
        if(1~=numel(unique(frame_tag(1:n_ch))))
            warning('Frame tags are different between channels.');
        end
        
        last_frame = floor(length(info_all)/n_ch)*n_ch;
        if(last_frame ~= length(info_all))
            warning('Total frames are not a multiple of n_ch.');
        end
        
        ch(ch==-1)=n_ch;
        load_frames = bsxfun(@plus,ch(:),0:n_ch:last_frame-1);

        if(isempty(load_frames))
            warning('No frame to read');
            stack=[];
            info = info_all([]);
            frame_tag = [];
        else
            info=info_all(load_frames(1,:));
            if(nargout>=3)
                frame_tag = get_frame_tag_from_info(info);
            end
            
            first_frame = imread(file_to_read,'tiff','index',load_frames(1));
            stack = zeros(size(first_frame,1),size(first_frame,2),size(load_frames,2),size(load_frames,1),class(first_frame));
            i_frame=1;i_ch=1;
            if(info_all(load_frames(i_ch,i_frame)).Width == size(first_frame,2) ...
                    && info_all(load_frames(i_ch,i_frame)).Height == size(first_frame,1))
                stack(:,:,i_frame,i_ch)=first_frame;
            else
                stack(:,:,i_frame,i_ch)=NaN;
            end
            i_chs_to_read = 1;
            for i_ch=2:size(load_frames,1)
                i_prev = find(ch(i_ch)==ch(1:i_ch-1),1,'first');
                if(isempty(i_prev))
                    i_chs_to_read(1,end+1)=i_ch;
                end
            end 
            for i_ch=i_chs_to_read(2:end)
                if(info_all(load_frames(i_ch,i_frame)).Width == size(first_frame,2) ...
                        && info_all(load_frames(i_ch,i_frame)).Height == size(first_frame,1))
                    stack(:,:,i_frame,i_ch) = imread(file_to_read,'tiff','index',load_frames(i_ch,i_frame));
                else
                    stack(:,:,i_frame,i_ch)=NaN;
                end
            end
            for i_frame = 2:size(load_frames,2)
                for i_ch=i_chs_to_read
                    if(info_all(load_frames(i_ch,i_frame)).Width == size(first_frame,2) ...
                            && info_all(load_frames(i_ch,i_frame)).Height == size(first_frame,1))
                        stack(:,:,i_frame,i_ch) = imread(file_to_read,'tiff','index',load_frames(i_ch,i_frame));
                    else
                        stack(:,:,i_frame,i_ch)=NaN;
                    end
                end
            end
            for i_ch=2:size(load_frames,1)
                i_prev = find(ch(i_ch)==ch(1:i_ch-1),1,'first');
                if(~isempty(i_prev))
                    stack(:,:,:,i_ch)=stack(:,:,:,i_prev);
                end
            end
        end
        if(~isempty(file_to_delete))
            delete(file_to_delete);
        end
    catch e
        if(~isempty(file_to_delete))
            delete(file_to_delete);
        end
        rethrow(e)
    end
end
