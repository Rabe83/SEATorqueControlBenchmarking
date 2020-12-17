%CJTSIMULINKLIBRARYTEST Test implementation of the Simulink block library.
%
% About this main function:
% The main function collects all of the local test functions
% into a test array. Since it is the main function, the function name
% corresponds to the name of your .m file and follows the naming convention
% of starting or ending in the word 'test', which is case-insensitive.
%
% To run tests from the command prompt, use the runtests command with your
% MATLAB test file as input. For example:
%
%   results = runtests('cjtSimulinkLibraryTest.m')
%
% Alternatively, you can run tests using the run function.
%
%   results = run(cjtSimulinkLibraryTest)
%
% To analyze the test results, examine the output structure from runtests
% or run. For each test, the result contains the name of the test function,
% whether it passed, failed, or didn't complete, and the time it took to
% run the test.
%
% Author::
%  Joern Malzahn
%  Wesley Roozing
%
% See also genericJoint.

% Copyright (C) 2016, by Joern Malzahn, Wesley Roozing
%
% This file is part of the Compliant Joint Toolbox (CJT).
%
% CJT is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% CJT is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
% License for more details.
%
% You should have received a copy of the GNU General Public License
% along with CJT. If not, see <http://www.gnu.org/licenses/>.
%
% For more information on the toolbox and contact to the authors visit
% <https://github.com/geez0x1/CompliantJointToolbox>

function [ tests ] = run(cjtSimulinkLibraryTest)
    tests = functiontests(localfunctions);
end

% Setup and teardown code, also referred to as test fixture functions,
% set up the pretest state of the system and return it to the original
% state after running the test. There are two types of these functions:
% FILE FIXTURE functions that run once per test file, and FRESH FIXTURE
% functions that run before and after each local test function. These
% functions are not required to generate tests. In general, it is
% preferable to use fresh fixtures over file fixtures to increase unit test
% encapsulation.
%
% A function test case object, testCase, must be the only input to file
% fixture and fresh fixture functions. The Unit Test Framework
% automatically generates this object.
% The TestCase object is a means to pass information between setup
% functions, test functions, and teardown functions. Its TestData property
% is, by default, a struct, which allows easy addition of fields and data.
% Typical uses for this test data include paths and graphics handles.


% ----------------- FILE FIXTURE -----------------------
function setupOnce(testCase)  % do not change function name
% set a new path, for example

    % cleanup console
    close all;
    clc;

    % instantiate a joint builder
    testCase.('TestData').JB = jointBuilder;
    testCase.('TestData').JB.overwrite = 1; % Overwrite existing model files.
    
    parName = 'cjt_Orange_80_6000';
    dynName = 'full_dyn';
    testCase.('TestData').className = ['cjt_Orange_80_6000','_','full_dyn'];%     Instantiate a joint model

    % build a joint class for the test
    testCase.('TestData').JB.buildJoint(parName,...
        dynName);
    addpath(testCase.('TestData').JB.buildDir) % Add the built directory of the
    % joint builder to the search path.
    testCase.('TestData').testJoint = eval(testCase.('TestData').className);
    
end

function teardownOnce(testCase)  % do not change function name
% change back to original path, for example

    close all
    rmpath(testCase.('TestData').JB.buildDir); % Remove the built directory from the search path, then
    testCase.('TestData').JB.purge;            % remove all files created during the tests

end

% % ----------------- FRESH FIXTURE -----------------------
function setup(testCase)  % do not change function name
   % Instantiate a fresh joint object
   testCase.('TestData').testJoint = eval(testCase.('TestData').className);
end
%
% function teardown(testCase)  % do not change function name
% % close figure, for example
% end
% % -----------------------------------------------

% Individual test functions are included as local functions in the same
% MATLAB file as the main (test-generating) function. These test function
% names must begin or end with the case-insensitive word, 'test'. Each of
%the local test functions must accept a single input, which is a function
% test case object, testCase. The Unit Test Framework automatically
% generates this object.
%
% A test function is also called a "Qualification". There exist different
% conceptual types of qualifications.
function testBuiltJoint(testCase)
    % Test specific code

    jObj = testCase.('TestData').testJoint;

    simOut = sim('simulinkBlockLibraryTest.mdl','SrcWorkspace','current');

    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = 'DDDF1AE0626D782B11B71D0C75F8B87B';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_02(testCase)
    % Test specific code

    % Run the example
    Ex_02_Current_Control_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '50EB85C7F629F9D1527CE393091993AC';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_03(testCase)
    % Test specific code

    % Run the example
    Ex_03_I_Control_Plus_Feedforward_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '93D29518D7032BBD9F4CF14A86ED409D';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_04(testCase)
    % Test specific code

    % Run the example
    Ex_04_PD_Control_Plus_Feedforward_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '3640A161985BBD7CE3AFBFA6F8116EC8';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
    
end

function testExample_05(testCase)
    % Test specific code

    % Run the example
    Ex_05_PD_Control_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = 'B054AA7EBE4D99212F55E016973ECAA3';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_06(testCase)
    % Test specific code

    % Run the example
    Ex_06_PD_Feedforward_OpenLoopDOB_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '760A93CEE2452F1E137AD139B9E185D8';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_07(testCase)
    % Test specific code

    % Run the example
    Ex_07_PD_OpenLoopDOB_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '68CA88D5E3B6430A9CCD0574CE4D3960';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_08(testCase)
    % Test specific code

    % Run the example
    Ex_08_PD_Feedforward_ClosedLoopDOB_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '7D11CACB5700871D0063D64DDADB6D1A';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_09(testCase)
    % Test specific code

    % Run the example
    Ex_09_PD_ClosedLoopDOB_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '7D11CACB5700871D0063D64DDADB6D1A';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_10(testCase)
    % Test specific code

    % Run the example
    Ex_10_Open_Loop_With_Disturbance_Observer_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '5C5C452FB4F5469581849B09FF558AD2';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_11(testCase)
    % Test specific code

    % Run the example
    Ex_11_Passivity_Based_Control_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '9A79781D932136DCE38D78065AD8A6E1';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_12(testCase)
    % Test specific code

    % Run the example
    Ex_12_Passivity_Based_Control_Plus_Disturbance_Observer_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '4C0FF77852B11FDA73E8A8B5697B2395';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_13(testCase)
    % Test specific code

    % Run the example
    Ex_13_Kalman_Estimator_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = '2E715A3DECEF386C6D9F37501BAD83B9';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

function testExample_14(testCase)
    % Test specific code

    % Run the example
    Ex_14_Luenberger_Observer_run
    
    % Close block diagrams after simulation during unit tests
    close_system(mdlName);

    % The example creates a variable simOut in the workspace. Use it to compute the checksum
    curChkSum = cjtComputeChecksum(simOut.yout(:));
    refChkSum = 'EBE941988C2D22DB43BCD95823B20503';

    import matlab.unittest.diagnostics.StringDiagnostic
    diagStr = sprintf(' Computed checksum: %s \n Reference: %s',curChkSum,refChkSum);
    verifyTrue(testCase, cjtCompareChecksum(curChkSum, refChkSum),...
        StringDiagnostic(diagStr) );
end

% function testFunctionalityTwo(testCase)
% % Test specific code
% end