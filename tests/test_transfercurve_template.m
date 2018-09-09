function test_suite = test_transfercurve_template
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_transfercurve_template_endtoend
    make_testing_colormodel;
    run template_analysis/transfercurve_template