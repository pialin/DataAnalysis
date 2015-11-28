
%实验数据选择
cd E:\Documents\Git\DataAnalysis\;

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

cfg.reref = 'yes';
cfg.refchannel = {'all','-HEO','-VEO','-EKG','-EMG'};

data2_CAR = ft_preprocessing(cfg);



%低通滤波滤除100Hz以上噪声(肌电)
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;

data3_LpFiltered = ft_preprocessing(cfg);



%滤波前后数据对比(前4096点)
figure;
Y1 = fft(data2_CAR.trial{1}(1,1:4096));
Y2 = fft(data3_LpFiltered.trial{1}(1,1:4096));
f = linspace(0,500,2048);

plot(f,abs(Y1(1:2048)),'b');
hold on;
plot(f,abs(Y2(1:2048)),'r');
hold off;

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
data4_trial  =  ft_preprocessing(cfg);

%显示分段后数据

cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;

ft_databrowser(cfg,data4_trial);


%滤除工频干扰
cfg.dftfilter = 'yes';
cfg.dftfreq = 50;
cfg.padtype = 'data';
cfg.padding = 10;


data5_notched = ft_preprocessing(cfg);



%滤波前后数据对比(trial1前4096点)
figure;
Y1 = fft(data4_trial.trial{1}(1,1:4096));
Y2 = fft(data5_notched.trial{1}(1,1:4096));

plot(f,abs(Y1(1:2048)));
hold on;
plot(f,abs(Y2(1:2048)),'r');
hold off;

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
%  [cfg, artifact_Jump] =
 ft_artifact_zvalue(cfg);



%用z阈值检测肌电伪迹
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = {'all','-HEO','-VEO','-EKG','-EMG'};
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
%  [cfg, artifact_EMG] =
 ft_artifact_zvalue(cfg);


%眼电

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     =  {'all','-HEO','-VEO','-EKG','-EMG'};
cfg.artfctdef.zvalue.cutoff      = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;
cfg.artfctdef.zvalue.fltpadding  = 0;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter   = 'yes';
cfg.artfctdef.zvalue.bpfilttype = 'but';
cfg.artfctdef.zvalue.bpfreq = [1 15];
cfg.artfctdef.zvalue.bpfiltord  = 4;
cfg.artfctdef.zvalue.hilbert  = 'yes';

% feedback
cfg.artfctdef.zvalue.interactive = 'yes';

%[cfg, artifact_EOG] = 
ft_artifact_zvalue(cfg);


% cfg = ft_rejectartifact(cfg);

%demean
cfg.demean='yes';
cfg.baselinewindow = [-1,0];
data6_demeaned = ft_preprocessing(cfg);


%detrend

cfg.detrend = 'yes';
data7_detrended = ft_preprocessing(cfg);

figure;
plot(data5_notched.trial{1}(1,1:7000),'b');
hold on;
plot(data6_demeaned.trial{1}(1,1:7000),'g');
plot(data7_detrended.trial{1}(1,1:7000),'r');
hold off;


cfgbackup = cfg;
% cfg = [];
%ICA去眼电
cfg.method = 'runica';

IcaComp = ft_componentanalysis(cfg,data1_SelectChannel);


cfg = rmfield(cfg,'method');

cfg.component = 1:8;       % specify the component(s) that should be plotted
cfg.layout    = 'quickcap64.mat'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
cfg = ft_topoplotIC(cfg, IcaComp );


cfg = rmfield(cfg,'channel');
cfg.component = 1:64;       % specify the component(s) that should be plotted
cfg.viewmode = 'component';

cfg = ft_databrowser(cfg, IcaComp );

cfg.component = 24; % to be removed component(s)
data8_EOGRemove = ft_rejectcomponent(cfg, IcaComp,  data7_detrended);


cfg.component = [19,64]; % to be removed component(s)
data8_EOGRemove = ft_rejectcomponent(cfg, IcaComp,  data7_detrended);

cfg.channel = {'all','-HEO','-VEO','-EKG','-EMG'};

cfg.viewmode = 'vertical';

ft_databrowser(cfg, data8_EOGRemove); 
figure;
plot(data7_detrended.trial{6}(1,:));
hold on;
plot(data8_EOGRemove.trial{6}(1,:),'r');
hold off;
figure;
cfg.method = 'channel';
% data6_rejected = 


ft_rejectvisual(cfg);


ft_rejectvisual(cfg,data7_detrended);
cfg.method = 'trial';
% data6_rejected = 
ft_rejectvisual(cfg,data8_EOGRemove);

cfg.method ='summary';
cfg = rmfield(cfg,'viewmode');
%data6_rejected = 
ft_rejectvisual(cfg,data7_detrended);








% cfg = [];

ERP  = ft_timelockanalysis(cfg, data8_EOGRemove);
cfg.showlabels = 'yes';
cfg.showoutline = 'yes';
cfg.baseline = [-1,0];
cfg.baselinetype  = 'relative';

figure;
ft_multiplotER(cfg, ERP);
ft_topoplotER(cfg,ERP);









