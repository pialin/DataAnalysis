%实验数据选择
CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];

cfg = [];

%原始数据读入
cfg.dataset = CntPath;

data0_original  = ft_preprocessing(cfg);

%原始数据显示
cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;
cfg = ft_databrowser(cfg);


%去掉不用的通道
cfg.channel = {'all','-HEO','-VEO','-EKG','-EMG'};

data1_SelectChannel = ft_preprocessing(cfg);


%低通滤波滤除100Hz以上噪声(肌电)
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;

data2_LpFiltered =  ft_preprocessing(cfg);


%滤波前后数据对比(前4096点)
figure;
Y1 = fft(data1_SelectChannel.trial{1}(1,1:4096));
Y2 = fft(data2_LpFiltered.trial{1}(1,1:4096));
f = linspace(0,500,2048);

plot(f,abs(Y1(1:2048)),'b');
hold on;
plot(f,abs(Y2(1:2048)),'r');


%处理event
event = ft_read_event(CntPath);
zerocell = num2cell(zeros(1,20));
[event(7:6:121).value]= zerocell{:};
cfg.event = event;




%数据分段
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 1:20;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 6; 
cfg.trialfun = 'ft_trialfun_general';

cfg.continuous = 'yes';

cfg = ft_definetrial(cfg); 
data3_trial  =  ft_preprocessing(cfg);

%显示分段后数据

cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;

ft_databrowser(cfg,data3_trial);


%滤除工频干扰
cfg.dftfilter = 'yes';
cfg.dftfreq = 50;
cfg.padtype = 'data';
cfg.padding = 10;


data4_notched = ft_preprocessing(cfg);
%滤波前后数据对比(trial1前4096点)
figure;
Y1 = fft(data3_trial.trial{1}(1,1:4096));
Y2 = fft(data4_notched.trial{1}(1,1:4096));

plot(f,abs(Y1(1:2048)));
hold on;
plot(f,abs(Y2(1:2048)),'r');

%用z阈值检测jump伪迹

cfg.artfctdef.zvalue.channel = {'all','-HEO','-VEO','-EKG','-EMG'};
cfg.artfctdef.zvalue.cutoff = 20;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;
 
% algorithmic parameters
cfg.artfctdef.zvalue.cumulative    = 'yes';
cfg.artfctdef.zvalue.medianfilter  = 'yes';
cfg.artfctdef.zvalue.medianfiltord = 9;
cfg.artfctdef.zvalue.absdiff       = 'yes';
 
% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';
%  [cfg, data4_rejectzvalue] =
 ft_artifact_zvalue(cfg);



%用z阈值检测肌电伪迹
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = [1:64,68];
cfg.artfctdef.zvalue.cutoff = 4;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0.1;
cfg.artfctdef.zvalue.fltpadding = 0;
 
% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [110 140];
cfg.artfctdef.zvalue.bpfiltord   = 9;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';
%  [cfg, data4_rejectzvalue] =
 ft_artifact_zvalue(cfg);


%眼电

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = [1:64,68];
cfg.artfctdef.zvalue.cutoff      = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;
cfg.artfctdef.zvalue.fltpadding  = 0;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter   = 'yes';
cfg.artfctdef.zvalue.bpfilttype = 'but';
cfg.artfctdef.zvalue.bpfreq     = [1 15];
cfg.artfctdef.zvalue.bpfiltord  = 4;
cfg.artfctdef.zvalue.hilbert    = 'yes';

% feedback
cfg.artfctdef.zvalue.interactive = 'yes';

%[cfg, artifact_EOG] = 
ft_artifact_zvalue(cfg);


cfg.method = 'channel';
data6_rejected = ft_rejectvisual(cfg,data5_detrended);

cfg.method = 'trial';
data6_rejected = ft_rejectvisual(cfg,data6_rejected);

cfg.method ='summary';
data6_rejected = ft_rejectvisual(cfg,data6_rejected);


cfg.dftfilter = 'no';



cfg.viewmode = 'butterfly';
cfg.blocksize = 7;
cfg.fontsize = 0.02;
ft_databrowser(cfg,data1_trial);




cfg = [];
cfg.channel =  1:64;
cfg.method = 'runica';
comp = ft_componentanalysis(cfg, data3_notched);

cfg.component = [1:64];       % specify the component(s) that should be plotted
cfg.layout    = 'quickcap64.mat'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
cfg = ft_topoplotIC(cfg, comp);



cfg.viewmode = 'component';
cfg = ft_databrowser(cfg, comp);

cfg.component = [29]; % to be removed component(s)
data4_EOGReject = ft_rejectcomponent(cfg, comp, data3_notched);


cfg.channel =  1:65;
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data4_EOGReject);


figure;
plot(data3_notched.trial{1}(58,1:7000));
hold on;
plot(data4_EOGReject.trial{1}(58,1:7000));


figure
plot(comp.trial{1}(35,:))
figure
y=fft(data4_EOGReject.trial{1}(58,:));
f=linspace(1,500,3500);
plot(f,abs(y(1:3500)));





%demean
cfg.demean='yes';
cfg.baselinewindow = [-1,0];
data4_demeaned = ft_preprocessing(cfg);

plot(data3_notched.trial{1}(1,1:5000));
hold on;
plot(data4_demeaned.trial{1}(1,1:5000));



%detrend
cfg = [];
cfg.detrend = 'yes';
data5_detrended = ft_preprocessing(cfg);


plot(data4_demeaned.trial{1}(1,1:5000));
hold on;
plot(data5_detrended.trial{1}(1,1:5000));



cfg = [];
cfg.channel  = [1:64];
tl  = ft_timelockanalysis(cfg, data1_trial);
cfg                 = [];
cfg.showlabels      = 'yes';
cfg.showoutline     = 'yes';
cfg.layout          = 'quickcap64.mat';

ft_multiplotER(cfg, tl);
ft_topoplotER(cfg,tl);







