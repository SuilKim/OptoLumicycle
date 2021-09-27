%%% Before running this, check the setting in a signal generator program and click the lumicyle program to make the current window.

clear all


%% ANALOG OUTPUT (PMT control)
s = daq.createSession('ni');
%initialize analog channel AO1 (controls PMT)
addAnalogOutputChannel(s,'Dev3',1,'Voltage');


%% Import the data
% Make sure that the sheet is updated and the data range is correctly set.
[~, ~, raw] = xlsread('C:\Users\McMahonLab\Desktop\Example sheet.xlsx','Sheet1','H5:P6'); 

%% Create output variable
StimMtx = reshape([raw{:}],size(raw));

%% Clear temporary variables
clearvars raw;

%% Initialize/User input
pmtstop=3;  %%DO NOT CHANGE MUST BE 3 TO TURN OFF PMTs
numStim = size(StimMtx);
numStim = numStim(1);
currentdate=clock;

for stim=1:numStim
    runtime(stim) = 60*StimMtx(stim,7);
end

%% Loop program for each stimulation entered
for stim=1:numStim
    
    waittime=etime(datevec(datetime([StimMtx(stim,1),StimMtx(stim,2),StimMtx(stim,3),StimMtx(stim,4),StimMtx(stim,5),0])), datevec(datetime('now'))); %% calculate wait period until program continues
    % etime does not take into account daylight savings or time zone changes.
      
    if waittime<0
        display('ERROR: Calculated Wait Time Negative!')
        continue
    end
    pause(waittime)   


    %% TURN OFF PMTs and move position
    s.outputSingleScan(pmtstop);
    pause(15)   % Make sure lumicycle has completed movement. This is sufficient unless a new stimulation begins in 2 mintues before a previous one.

    %% Give matlab keyboard control to move position

    import java.awt.Robot
    import java.awt.event.*
    robot = Robot();
    eval(['robot.keyPress(KeyEvent.VK_',num2str(StimMtx(stim,6)),')'])
    eval(['robot.keyRelease(KeyEvent.VK_',num2str(StimMtx(stim,6)),')'])
          
    pause(44.95) % Make sure lumicycle has completed movement

    %% Signal Generator Control 
    % This works because the screen coordinates of the signal generator program is pre-set.
    % Make sure signal generator is OFF.
    
    % Turn ON the generator
    import java.awt.Robot
    import java.awt.event.*
    robot = Robot();
    robot.mouseMove(216,875) % The coordinates for an icon of signal generator software in taskbar
    robot.mousePress(1024)
    robot.mouseRelease(1024)
    robot.mouseMove(1070,270) % The coordinates for an ON button
    pause(0.05)
    robot.mousePress(1024)
    robot.mouseRelease(1024)
    
    StimulationStart=datetime('now')
    totaltime=tic;
    
    pause(runtime(stim)) % The generator is on for this duration.
    
    % Turn OFF the generator
    import java.awt.Robot
    import java.awt.event.*
    robot = Robot();
    robot.mouseMove(1070,270) % The coordinates for an ON button
    robot.mousePress(1024)
    robot.mouseRelease(1024)
    
    toc(totaltime)
    StimulationEnd=datetime('now')
    
    % Click the lumicycle program to make position-moving work again for the next stimulation.
    import java.awt.Robot
    import java.awt.event.*
    robot = Robot();
    robot.mouseMove(170,875) % The coordinates for lumicycle icon in taskbar
    robot.mousePress(1024)
    robot.mouseRelease(1024)
    
    % Turn ON PMTs
    s.outputSingleScan(0);
end


%% program end
return