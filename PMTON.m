
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,'Dev3',1,'Voltage');
    s.outputSingleScan([0]);
   