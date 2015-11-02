
%环境变量设置
CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];

cfg.dataset = CntPath;

cfg.viewmode = 'vertical';

ft_databrowser(cfg);


cfg = [];

%处理event
event = ft_read_event(CntPath);
cellzero = num2cell(zeros(1,20));
[event(7:6:121).value]= cellzero{:};
cfg.event = event;

%读入数据并分段

cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 1:20;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 6; 
cfg.trialfun = 'ft_trialfun_general';

cfg = ft_definetrial(cfg); 
data1_trial  =  ft_preprocessing(cfg);

%导联选择(去除HEO VEO EKG 3个没有采集的导联)
cfg.channel = [1:64,68];

data2_SelectedChannel = ft_preprocessing(cfg);

%滤除工频干扰
cfg.dftfilter = 'yes';
cfg.dftfreq = 50;
cfg.continuous = 'yes';
cfg.padtype = 'data';
cfg.padding = 10;


data3_notched = ft_preprocessing(cfg);
figure;
y1 = fft(data2_SelectedChannel.trial{1}(1,1:4096));
y2 = fft(data3_notched.trial{1}(1,1:4096));

plot(abs(y1(1:2048)));
hold on;
plot(abs(y2(1:2048)),'r');

%jump
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = [1:64,68];
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

plot(data1_trial.trial{1}(57,2000:3000));




%肌电
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







