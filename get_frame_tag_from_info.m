function frame_tag = get_frame_tag_from_info(info)
    frame_tag = -ones(size(info)); % -1 indicates no valid frame_tag
    for i=1:numel(info)
        if(isfield(info(i),'ImageDescription') && ~isempty(info(i).ImageDescription))
            if(info(i).ImageDescription(1)=='f')
                %ScanImage 5
                tmp = str2double(regexp(info(i).ImageDescription,'frameNumbers = (\d*)','tokens','once'));
            else
                %ScanImage 4
                tmp = str2double(regexp(info(i).ImageDescription,'Frame Tag = (\d*)','tokens','once'));
            end
            if(~isempty(tmp))
                frame_tag(i) = tmp;
            end
        end
    end
end