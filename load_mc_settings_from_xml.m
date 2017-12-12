function [params_mc, params_tf, ffn_xml] = load_mc_settings_from_xml(pathstr)
    fn_xml = {};
    if(exist('pathstr','var'))
        while(1)
            fn_xml = [fn_xml, {fullfile(pathstr,'motion_correct.xml')}]; %#ok<AGROW>
            if(strcmp(fileparts(pathstr),pathstr))
                break;
            else
                [pathstr,~]=fileparts(pathstr);
            end
        end
    end
    if(exist('motion_correct.xml','file'))
        fn_xml = [fn_xml {which('motion_correct.xml')}];
    end
    ffn_xml = '';
    for i=1:length(fn_xml)
        if(exist(fn_xml{i},'file'))
            ffn_xml=fn_xml{i};
            break;
        end
    end
    if(isempty(ffn_xml))
        params_mc = [];
        params_tf = [];
    else
        xml_struct=xml2struct(ffn_xml); % https://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
        params_mc_names = {'factor','marginh','marginw','sigmaSmoothing','sigmaNormalization','normalizationOffset'...
            ,'toEqualizeHistogram','threshold','replacement','margin_running'};
        for i=1:length(params_mc_names)
            try
                params_mc.(params_mc_names{i}) = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.(params_mc_names{i}).Text);
            catch e
                disp(e.message)
                params_mc.(params_mc_names{i}) = 0;
            end
        end
        params_tf = [];
    end
end

