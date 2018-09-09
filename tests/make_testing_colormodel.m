function make_testing_colormodel()

if exist('template_colormodel/CM120312.mat','file')
    return;
end

%%%%%%%%%%%%%%%%
% if it doesn't already exist, make it:
run template_colormodel/make_color_model