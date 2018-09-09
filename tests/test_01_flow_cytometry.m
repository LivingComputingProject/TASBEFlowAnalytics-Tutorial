function test_suite = test_01_flow_cytometry
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_01_flow_cytometry_endtoend
    run 01_flow_cytometry/exercises 
