% =========================================================================
% *** FUNCTION fGetSeed
% ***
% *** A little GUI to select a seed
% ***
% =========================================================================
function iSeed = fGetSeed(dImg)
iSlice = 1;
dImg = dImg./max(dImg(:));
dImg = dImg - min(dImg(:));
iImg = uint8(dImg.*255);
try
    hF = figure(...
        'Position'             , [0 0 size(dImg, 2) size(dImg, 1)], ...
        'Units'                , 'pixels', ...
        'Color'                , 'k', ...
        'DockControls'         , 'off', ...
        'MenuBar'              , 'none', ...
        'Name'                 , 'Select Seed', ...
        'NumberTitle'          , 'off', ...
        'BusyAction'           , 'cancel', ...
        'Pointer'              , 'crosshair', ...
        'CloseRequestFcn'      , 'delete(gcbf)', ...
        'WindowButtonDownFcn'  , 'uiresume(gcbf)', ...
        'KeyPressFcn'          , @fKeyPressFcn, ...
        'WindowScrollWheelFcn' , @fWindowScrollWheelFcn);
catch
    hF = figure(...
        'Position'             , [0 0 size(dImg, 2) size(dImg, 1)], ...
        'Units'                , 'pixels', ...
        'Color'                , 'k', ...
        'DockControls'         , 'off', ...
        'MenuBar'              , 'none', ...
        'Name'                 , 'Select Seed', ...
        'NumberTitle'          , 'off', ...
        'BusyAction'           , 'cancel', ...
        'Pointer'              , 'crosshair', ...
        'CloseRequestFcn'      , 'delete(gcbf)', ...
        'WindowButtonDownFcn'  , 'uiresume(gcbf)', ...
        'KeyPressFcn'          , @fKeyPressFcn);
end

hA = axes(...
    'Parent'                , hF, ...
    'Position'              , [0 0 1 1]);
hI = image(iImg(:,:,1), ...
    'Parent'                , hA, ...
    'CDataMapping'          , 'scaled');

colormap(gray(256));
movegui('center');

uiwait;

if ~ishandle(hF)
    iSeed = [];
else
    iPos = uint16(get(hA, 'CurrentPoint'));
    iSeed = [iPos(1, 2) iPos(1, 1) iSlice];
    delete(hF);
end

    % ---------------------------------------------------------------------
    % * * NESTED FUNCTION fKeyPressFcn (nested in fGetSeed)
    % * *
    % * * Changes the active slice
    % ---------------------------------------------------------------------
    function fKeyPressFcn(hObject, eventdata)
        switch(eventdata.Key)
            case 'uparrow'
                iSlice = min([size(iImg, 3), iSlice + 1]);
                set(hI, 'CData', iImg(:,:,iSlice));
                
            case 'downarrow'
                iSlice = max([1, iSlice - 1]);
                set(hI, 'CData', iImg(:,:,iSlice));
        end
    end
    % ---------------------------------------------------------------------
    % * * END OF NESTED FUNCTION fKeyPressFcn (nested in fGetSeed)
    % ---------------------------------------------------------------------
    
    
    % ---------------------------------------------------------------------
    % * * NESTED FUNCTION fWindowScrollWheelFcn (nested in fGetSeed)
    % * *
    % * * Changes the active slice
    % ---------------------------------------------------------------------
    function fWindowScrollWheelFcn(hObject, eventdata)
        iSlice = min([size(iImg, 3), iSlice + eventdata.VerticalScrollCount]);
        iSlice = max([1, iSlice]);
        set(hI, 'CData', iImg(:,:,iSlice));
    end
    % ---------------------------------------------------------------------
    % * * END OF NESTED FUNCTION fWindowScrollWheelFcn (nested in fGetSeed)
    % ---------------------------------------------------------------------

end
% =========================================================================
% *** END FUNCTION fGetSeed (and its nested function)
% =========================================================================