function im=parse_image_input(im,ch)
    if(nargin<2)
        ch=1;
    end
    if(ischar(im))
        im = read_tiff(im);
    end
    if(iscell(im))
        if(ch<0)
            im = im{end};
        elseif(numel(im)>= ch)
            im = im{ch};
        else
            im = im{1};
        end
    end
    if(ch<0)
        im = im(:,:,end);
    elseif(size(im,3)>=ch)
        im = im(:,:,ch);
    else
        im = im(:,:,1);
    end
end