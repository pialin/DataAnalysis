%ʵ������ѡ��
CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];

cfg = [];

%ԭʼ���ݶ���
cfg.dataset = CntPath;

data0_original  = ft_preprocessing(cfg);

%ԭʼ������ʾ
cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;
cfg = ft_databrowser(cfg);


%ȥ�����õ�ͨ��
cfg.channel = {'all','-HEO','-VEO','-EKG','-EMG'};

data1_SelectChannel = ft_preprocessing(cfg);

cfg.reref = 'yes';
cfg.refchannel = 'all';

data2_CAR = ft_preprocessing(cfg);



%��ͨ�˲��˳�100Hz��������(����)
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;

data3_LpFiltered =  ft_preprocessing(cfg);

cfg.lpfilter = [];
cfg.lpfreq = [];


%�˲�ǰ�����ݶԱ�(ǰ4096��)
figure;
Y1 = fft(data2_CAR.trial{1}(1,1:4096));
Y2 = fft(data3_LpFiltered.trial{1}(1,1:4096));
f = linspace(0,500,2048);

plot(f,abs(Y1(1:2048)),'b');
hold on;
plot(f,abs(Y2(1:2048)),'r');


%����event
event = ft_read_event(CntPath);
zerocell = num2cell(zeros(1,20));
[event(7:6:121).value]= zerocell{:};
cfg.event = event;




%���ݷֶ�
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 1:20;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 6; 
cfg.trialfun = 'ft_trialfun_general';

cfg.continuous = 'yes';

cfg = ft_definetrial(cfg); 
data4_trial  =  ft_preprocessing(cfg);

%��ʾ�ֶκ�����

cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;

ft_databrowser(cfg,data4_trial);


%�˳���Ƶ����
cfg.dftfilter = 'yes';
cfg.dftfreq = 50;
cfg.padtype = 'data';
cfg.padding = 10;


data5_notched = ft_preprocessing(cfg);

cfg.dftfilter = [];
cfg.dftfreq = [];
cfg.padtype = [];
cfg.padding = [];


%�˲�ǰ�����ݶԱ�(trial1ǰ4096��)
figure;
Y1 = fft(data4_trial.trial{1}(1,1:4096));
Y2 = fft(data5_notched.trial{1}(1,1:4096));

plot(f,abs(Y1(1:2048)));
hold on;
plot(f,abs(Y2(1:2048)),'r');

%��z��ֵ���jumpα��

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



%��z��ֵ��⼡��α��
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
%  [cfg, artifact_EMG] =
 ft_artifact_zvalue(cfg);


%�۵�

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = [1:64,68];
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
cfg = [];
cfg.detrend = 'yes';
data7_detrended = ft_preprocessing(cfg);

figure;
plot(data5_notched.trial{1}(1,1:5000));
hold on;
plot(data6_demeaned.trial{1}(1,1:5000));
plot(data7_detrended.trial{1}(1,1:5000));
hold off;


% cfg = [];
%ICAȥ�۵�
cfg.method = 'runica';
comp = ft_componentanalysis(cfg, data7_detrended);

cfg.component = 1:8;       % specify the component(s) that should be plotted
cfg.layout    = 'quickcap64.mat'; % specify the layout file that should be used for plotting
cfg.comment   = 'yes';
cfg = ft_topoplotIC(cfg, comp);


cfg.component = 1:64;       % specify the component(s) that should be plotted
cfg.viewmode = 'component';
cfg = ft_databrowser(cfg, comp);

cfg.component = [29]; % to be removed component(s)
data8_EOGRemove = ft_rejectcomponent(cfg, comp,  data7_detrended);

cfg.viewmode = 'vertical';

ft_databrowser(cfg, data8_EOGRemove);



cfg.method = 'channel';
% data6_rejected = 
ft_rejectvisual(cfg,data4_notched );

cfg.method = 'trial';
% data6_rejected = 
ft_rejectvisual(cfg);

cfg.method ='summary';
%data6_rejected = 
ft_rejectvisual(cfg);








% cfg = [];

ERP  = ft_timelockanalysis(cfg, data8_EOGRemove);
cfg = [];
cfg.showlabels = 'yes';
cfg.showoutline = 'yes';
cfg.layout = 'quickcap64.mat';

ft_multiplotER(cfg, ERP);
ft_topoplotER(cfg,ERP);







