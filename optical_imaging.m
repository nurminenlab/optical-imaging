% script to run imaging experiments
vid = videoinput("pcocameraadaptor_r2023b", 0, "USB 3.1 Gen 1");
figure('Name', 'My Custom Preview Window');
uicontrol('String', 'Kill', 'Callback', 'delete(vid), clear("vid"), close(gcf)');
vidRes = get(vid, 'VideoResolution');
nBands = get(vid, 'NumberOfBands');
subplot(2,2,1);
hImage = image(zeros(vidRes(2),vidRes(1),nBands));

setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);

preview(vid, hImage);

function update_livehistogram_display(obj,event,hImage)
    % This callback function updates the displayed frame and the histogram.
    
    % Copyright 2007-2017 The MathWorks, Inc.
    %
    % Display the current image frame.
    set(hImage, 'CData', event.Data);
    
    % Select the second subplot on the figure for the histogram.
    subplot(2,2,2);
    
    % Plot the histogram. Choose 128 bins for faster update of the display.
    histogram(event.Data(:), 128);
    
    % Refresh the display.
    drawnow
end




