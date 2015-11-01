
%环境变量设置
CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];



cfg = [];

%处理event
event = ft_read_event(CntPath);
cellzero = num2cell(zeros(1,20));
[event(7:6:121).value]= cellzero{:};
cfg.event = event;

%读入数据并分段
cfg.dataset = CntPath;
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
cfg.continuous = 'yes';
cfg.padtype = 'data';
cfg.padding = 10;
cfg.dftfreq = 50;

data3_notched = ft_preprocessing(cfg);
y1 = fft(data2_SelectedChannel.trial{1}(1,1:4096));
y2 = fft(data3_notched.trial{1}(1,1:4096));

plot(abs(y1(1:2048)));
hold on;
plot(abs(y2(1:2048)),'r');


% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel    = [1:64,68];
cfg.artfctdef.zvalue.cutoff     = 20;
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
 
[cfg, data4_rejectzvalue] = ft_artifact_zvalue(cfg);

plot(data1_trial.trial{1}(57,2000:3000));

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


cfg.method = 'channel';
data6_rejected = ft_rejectvisual(cfg,data5_detrended);

cfg.method = 'trial';
data6_rejected = ft_rejectvisual(cfg,data6_rejected);

cfg.method ='summary';
data6_rejected = ft_rejectvisual(cfg,data6_rejected);


%移除

cfg = ft_artifact_jump(cfg);
cfg = ft_rejectartifact(cfg);



%滤波(50,100,150Hz陷波)
data_cnt.trial{1}(1,5000:end)=[];
cfg=[];
cfg.dftfilter = 'yes';
cfg.dftfreq = [50];
data_notched =  ft_preprocessing(cfg,data_cnt);

data_notched=ft_preproc_dftfilter(data_cnt.trial{1}(1,1:5000), 1000, [50,100,150]);

cfg=[];
cfg.viewmode = 'vertical';
cfg.channel = 'HEO';
ft_databrowser(cfg,data_notched);
ft_databrowser(cfg,data_cnt);



hold on;
plot(data_notched.trial{1}(1,1:5000)-10,'r');





z = num2cell(zeros(1,20));
[event(8:6:122).value]= z{:};


cfg=[];
cfg.event=event;
cfg.trialdef.prestim =1;
cfg.trialdef.poststim =6;
cfg.trialdef.eventtype='stimtype';
cfg.trialdef.eventvalue=1:20;
cfg.dataset=CntPath;


cfg=ft_definetrial(cfg);


data_raw = ft_preprocessing(cfg);


cfg.viewmode='vertical';
cfg=ft_databrowser(cfg);


cfg.method ='summary';
% cfg.alim=5e-5;
ft_rejectvisual(cfg,data_raw)
