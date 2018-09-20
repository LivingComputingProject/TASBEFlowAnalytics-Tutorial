function test_suite = test_02_flow_compensation
    % TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_02_flow_compensation_endtoend
    set(0,'DefaultFigureVisible','off')
    run 02_flow_compensation/exercises
    set(0,'DefaultFigureVisible','on')
     
