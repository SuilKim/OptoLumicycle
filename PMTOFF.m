
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,'Dev3',1,'Voltage');
    pmtstop=3;  %%DO NOT CHANGE MUST BE 3 TO TURN OFF PMTs
    s.outputSingleScan([pmtstop]);
    

   