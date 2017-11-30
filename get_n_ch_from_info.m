function n_ch = get_n_ch_from_info(info)
    n_ch = NaN;
    i = 1;
    if(isfield(info(i),'ImageDescription') && ~isempty(info(i).ImageDescription))
        if(info(i).ImageDescription(1)=='f')
            %ScanImage 5
            SI = assignments2StructOrObj(info(1).Software);
            n_ch = numel(SI.hChannels.channelSave);
        else
            %ScanImage 4
            tmp = assignments2StructOrObj(info(1).ImageDescription);
            n_ch = numel(tmp.SI4.channelsSave);
        end
    end
end