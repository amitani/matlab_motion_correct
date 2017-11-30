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
        params_mc.factor = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.factor.Text);
        params_mc.marginh = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.marginh.Text);
        params_mc.marginw = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.marginw.Text);
        params_mc.sigmaSmoothing = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.sigmaSmoothing.Text);
        params_mc.sigmaNormalization = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.sigmaNormalization.Text);
        params_mc.normalizationOffset = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.normalizationOffset.Text);
        params_mc.toEqualizeHistogram = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.toEqualizeHistogram.Text);
        params_mc.threshold = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.threshold.Text);
        params_mc.replacement = str2double(xml_struct.motionCorrectionSetting.cvMotionCorrect.replacement.Text);
        params_tf.r1 = str2double(xml_struct.motionCorrectionSetting.findTransform.r1.Text);
        params_tf.r2 = str2double(xml_struct.motionCorrectionSetting.findTransform.r2.Text);
        params_tf.offset = str2double(xml_struct.motionCorrectionSetting.findTransform.offset.Text);
        params_tf.factor = str2double(xml_struct.motionCorrectionSetting.findTransform.factor.Text);
        params_tf.depth = str2double(xml_struct.motionCorrectionSetting.findTransform.depth.Text);
        params_tf.step = str2double(xml_struct.motionCorrectionSetting.findTransform.step.Text);
        params_tf.transform = xml_struct.motionCorrectionSetting.findTransform.transform.Text;
        params_tf.marginRatio = str2double(xml_struct.motionCorrectionSetting.findTransform.marginRatio.Text);
        params_tf.initialization = str2double(xml_struct.motionCorrectionSetting.findTransform.initialization.Text);
    end
end