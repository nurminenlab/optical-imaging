% [~,hostname] = system('hostname');
% hostname = string(strtrim(hostname));
% address = resolvehost(hostname,"address");
% server = tcpserver(address,5000);
%     disp('Waiting for stimulus PC')
% while server.NumBytesAvailable ~= 2
% end

imaqreset();
% script to run imaging experiments
vid = videoinput("pcocameraadaptor_r2023b", 0, "USB 3.1 Gen 1");
vidRes = get(vid, 'VideoResolution'); %#ok<NASGU>
nBands = get(vid, 'NumberOfBands'); %#ok<NASGU>

framesPerTrigger = 1;
numTriggers = 600;
triggerCondition = "";
triggerSource = "ExternExposureStart";
imaging_exposure = 0.005;
FR = 120; % frame rate
src = getselectedsource(vid);
src.ExposureTime_s = imaging_exposure;

button_width   = 140;
button_height  = 140;
top_button     = 900;
between_button = 10;

im_fig = figure('Name', 'Imaging');
set(gcf, 'Position', get(0, 'Screensize'));
set(gcf,'menubar','none')

uicontrol('String', 'Kill', 'Callback', 'delete(vid), clear("vid"), close(gcf)','Position',[20,top_button,button_width,button_height],'BackgroundColor',[1 0 0],'FontSize',14, 'FontWeight','bold');
uicontrol('String', 'Green image', 'Callback', 'uiresume(im_fig), Y = getsnapshot(vid);','Position',[20,top_button-button_height,button_width,button_height],'BackgroundColor',[0 1 0],'FontSize',14, 'FontWeight','bold');
uicontrol('String', 'ROI', 'Callback', 'uiresume(im_fig)','Position',[20,top_button-2*button_height,button_width,button_height],'BackgroundColor',[1 1 0],'FontSize',14, 'FontWeight','bold');
uicontrol('String', 'Acquire', 'Callback', 'uiresume(im_fig), closepreview(vid);','Position',[20,top_button-3*button_height,button_width,button_height],'BackgroundColor',[1 1 0],'FontSize',14, 'FontWeight','bold');

% big image to set ROI
subplot(2,2,1);
hImage1 = image(zeros(vidRes(2),vidRes(1),nBands));
preview(vid, hImage1);
uiwait(im_fig); % wait while brightness is set
h = images.roi.Rectangle(gca,'Position',[0,0,1280,512],'StripeColor','r');
uiwait(im_fig); % wait while brightness is set
coords = floor(h.Position);
closepreview(vid);

% set hardware ROI
src = getselectedsource(vid);
src.H2HardwareROI_Width = coords(3);
src.H1HardwareROI_X_Offset = coords(1);
src.H5HardwareROI_Height = coords(4);
src.H4HardwareROI_Y_Offset = coords(2);

% preview window for setting up the lights
subplot(2,2,2);
vidRes = get(vid, 'VideoResolution'); %#ok<NASGU>
nBands = get(vid, 'NumberOfBands'); %#ok<NASGU>
hImage1 = image(zeros(vidRes(2),vidRes(1),nBands));
preview(vid, hImage1);
uiwait(im_fig); % wait while brightness is set
closepreview(vid);

% preview window for setting up the lightssubplot(2,2,3);
global ax; %#ok<GVMIS>
src.ExposureTime_s = imaging_exposure; % 5 ms exposure time per Augustinaite & Kuhn
ax = subplot(2,2,3);
vid.PreviewFullBitDepth = "on";
hImage = image(zeros(vidRes(2),vidRes(1),nBands));
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
preview(vid, hImage);
uiwait(im_fig);

triggerconfig(vid, "hardware", triggerCondition, triggerSource);
vid.FramesPerTrigger = framesPerTrigger;
vid.TriggerRepeat = Inf;
vid.FramesAcquiredFcn = @compute_averages;
vid.FramesAcquiredFcnCount = numTriggers;
start(vid);

%%%%%%%%%%%%%%%%%%%
function compute_averages(obj,event)
    Y = getdata(obj,obj.FramesAcquiredFcnCount);   %#ok<NASGU>
end
function update_livehistogram_display(obj,event,hImage)
    % This callback function updates the displayed frame and the histogram.
    maxV = 2^16 - 1;
    global ax; %#ok<REDEFGI,GVMIS>

    % Copyright 2007-2017 The MathWorks, Inc.
    %
    % Display the current image frame.
    set(hImage, 'CData', (event.Data./maxV)*256);
    colormap(ax,jet); colorbar;

    % Select the second subplot on the figure for the histogram.
    subplot(2,2,4);
    
    % Plot the histogram. Choose 128 bins for faster update of the display.
    histogram(event.Data(:), 128);
    axis([0, 2^16-1, 0, 3*10^4]);

    % Refresh the display.
    drawnow
end





