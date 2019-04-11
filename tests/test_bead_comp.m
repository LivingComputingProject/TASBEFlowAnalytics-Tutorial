function test_suite = test_bead_comp
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_bead_comp_endtoend
    run template_colormodel/bead_comparison
