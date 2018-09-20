function test_suite = test_03_flow_MEFL
    % TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_03_flow_MEFL_endtoend
    set(0,'DefaultFigureVisible','off')
    run 03_flow_MEFL/exercises
    set(0,'DefaultFigureVisible','on')