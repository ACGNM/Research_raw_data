function varargout = Research_APP(varargin)
% RESEARCH_APP MATLAB code for Research_APP.fig
%      RESEARCH_APP, by itself, creates a new RESEARCH_APP or raises the existing
%      singleton*.
%
%      H = RESEARCH_APP returns the handle to a new RESEARCH_APP or the handle to
%      the existing singleton*.
%
%      RESEARCH_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESEARCH_APP.M with the given input arguments.
%
%      RESEARCH_APP('Property','Value',...) creates a new RESEARCH_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Research_APP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Research_APP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Research_APP

% Last Modified by GUIDE v2.5 24-Oct-2017 00:50:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Research_APP_OpeningFcn, ...
                   'gui_OutputFcn',  @Research_APP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Research_APP is made visible.
function Research_APP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Research_APP (see VARARGIN)

% Choose default command line output for Research_APP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Research_APP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Research_APP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sr = 44100;
time = 3;

robj = audiorecorder(sr,16,1);
recordblocking(robj,time);           
sound_data = getaudiodata(robj);

axes(handles.signal);
plot(sound_data); 
set(gca,'xticklabel',{[]});
set(gca,'xgrid','on');
axis([1,132300,-0.2,0.2]);
title('Sound Signal');

save('sound_data.mat','sound_data');

[D,F] = gammatonegram(sound_data,sr);
tem = 20*log10(D);
tem(tem==-Inf) = min(tem(tem~=-Inf));

map = parula();
L = size(map,1);
if size(D,2)==298
    bin_img = tem(:,25:298);
end
Gs = round(interp1(linspace(min(bin_img(:)),max(bin_img(:)),L),1:L,bin_img));
H = reshape(map(Gs,:),[size(Gs) 3]); 
imwrite(H, map, 'test_color_img.png');

axes(handles.spectrogram);
imagesc(tem); axis xy
colormap(handles.spectrogram,'parula');
set(gca,'xticklabel',{[]});
set(gca,'YTickLabel',round(F(get(gca,'YTick'))));
ylabel('freq / Hz');
title('Spectrogram with Gammatone filter');

axes(handles.binary);
imagesc(Binary_Wellner(D)); axis xy
colormap(handles.binary,'gray');
set(gca,'YTickLabel',round(F(get(gca,'YTick'))));
ylabel('freq / Hz');
xlabel('time / 10 ms steps');
title('Binarized Gammatonegram');



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load color_net.mat
img = imread('test_color_img.png');

predictedLabels = classify(net,img);

set(handles.result,'String',char(predictedLabels(1)));
