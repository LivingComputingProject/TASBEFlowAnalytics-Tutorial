function test_suite = test_batch_template_csv
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_batch_template_csv_endtoend
    make_testing_colormodel;
    run template_analysis/batch_template_csv