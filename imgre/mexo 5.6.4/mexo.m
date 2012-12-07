classdef mexo < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    
    methods
        % constructor
        function obj = mexo()
            obj.obj_handle = texo_constructor();
        end
        % destructor
        function delete(obj)
            obj.shutdown();
            texo_destructor(obj.obj_handle);
        end
        %methods
        function bool = activateProbeConnector(obj, probe)
            bool = texo_activateProbeConnector(obj.obj_handle, ...
                int32(probe));
        end
        function bool = addFlatTGC(obj, percent)
            bool = texo_addFlatTGC(obj.obj_handle, double(percent));
        end
        function bool = addTGC(obj, percent)
            bool = texo_addTGC(obj.obj_handle, double(percent));
        end
        function bool = addLine(obj, dataFormat, tx, rx)
            bool = texo_addLine(obj.obj_handle, dataFormat, ...
                tx.obj_handle, rx.obj_handle);
        end
        function bool = addReceive(obj, rx)
            bool = texo_addReceive(obj.obj_handle, rx.obj_handle);
        end
        function bool = addTransmit(obj, tx)
            bool = texo_addTransmit(obj.obj_handle, tx.obj_handle);
        end
        function bool = beginSequence(obj)
            bool = texo_beginSequence(obj.obj_handle);
        end
        function clearTGCs(obj)
            texo_clearTGCs(obj.obj_handle);
        end
        function bool = collectFrames(obj, value)
            bool = texo_collectFrames(obj.obj_handle, value);
        end
        function bool = isImaging(obj)
            bool = texo_isImaging(obj.obj_handle);
        end
        function bool = init(obj, firmwarePath, pci, usm, hv, channels, ...
                tx, szCine)
            bool = texo_init(obj.obj_handle, firmwarePath, int32(pci), ...
                int32(usm), int32(hv), int32(channels), int32(tx), ...
                int32(szCine));
        end
        function bool = isInitialized(obj)
            bool = texo_isInitialized(obj.obj_handle);
        end
        function bool = endSequence(obj)
            bool = texo_endSequence(obj.obj_handle);
        end
        function data = getCine(obj, value)
            data = texo_getCine(obj.obj_handle, value);
        end
        function ptr = getCineStart(obj, value)
           ptr = texo_getCineStart(obj.obj_handle, value);
        end
        function value = getCollectedFrameCount(obj)
            value = texo_getCollectedFrameCount(obj.obj_handle);
        end
        function value = getFrameSize(obj)
            value = texo_getFrameSize(obj.obj_handle);
        end
        function value = getMaxFrameCount(obj)
            value = texo_getMaxFrameCount(obj.obj_handle);
        end
        function bool = runImage(obj)
            bool = texo_runImage(obj.obj_handle);
        end
        function bool = setPower(obj, power, maxPositive, maxNegative)
            bool = texo_setPower(obj.obj_handle, int32(power), ...
                int32(maxPositive), int32(maxNegative));
        end
        function bool = setSyncSignals(obj, input, output, output2)
            bool = texo_setSyncSignals(obj.obj_handle, int32(input), ...
                int32(output), int32(output2));
        end
        function bool = shutdown(obj)
            bool = texo_shutdown(obj.obj_handle);
        end
        function bool = stopImage(obj)
            bool = texo_stopImage(obj.obj_handle);
        end
    end
end

