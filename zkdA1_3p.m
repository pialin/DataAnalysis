%zkdA1_3.cnt�����ű�

clear;
%%
%ʵ������ѡ��
cd E:\Documents\Git\DataAnalysis\;

CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'_',num2str(WhichExp),'.cnt'];

%%
%���ݷֶ�(ֻ����trial�����ص㣬��δʵ�ʽ������ݵĽ�ȡ)
cfg=[];

%���ݼ�ָ��
cfg.dataset = CntPath;

%����event
event = ft_read_event(CntPath);
zerocell = num2cell(zeros(1,20));
[event(7:6:121).value]= zerocell{:};
cfg.event = event;


cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 1:20;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 6; 
cfg.trialfun = 'ft_trialfun_general';

cfg = ft_definetrial(cfg); 

%��trial�ֶ���Ϣ�����ڱ���trl��
trl = cfg.trl; 

%%
%��zֵȥα��
cfg = [];

%���ݼ�ָ��
cfg.dataset = CntPath;

cfg.trl = trl;
cfg.continuous  = 'yes';

%��z��ֵ���jumpα��

cfg.artfctdef.zvalue.channel =  {'all','-HEO','-VEO','-EKG','-EMG','-M1','-M2','-CB1','-CB2'};
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
%  [cfg, Artifact_Jump] =
ft_artifact_zvalue(cfg);



%��z��ֵ��⼡��α��
% channel selection, cutoff and padding
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
%  [cfg, Artifact_EMG] =
ft_artifact_zvalue(cfg);


%��z��ֵ����۵�α��
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.cutoff = 4;
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

% [cfg, Artifact_EOG] = 
ft_artifact_zvalue(cfg);


% cfg = ft_rejectartifact(cfg);
% trl = cfg.trl;

%%
%�������ݴ����زο�,��ͨ�˲�,detrend��
cfg = [];

%ָ������
cfg.channel = {'all','-HEO','-VEO','-EKG','-EMG','-M1','-M2','-CB1','-CB2'};
%ָ�����ݼ�
cfg.dataset = CntPath;

%�زο�����ƽ���ο���
cfg.reref = 'yes';
cfg.refchannel = cfg.channel ;

%100Hz��ͨ�˲�
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;

%ȥ���źŵ���������
cfg.detrend = 'yes';

data1_ContinPreproc = ft_preprocessing(cfg);

% cfg = [];
% cfg.dataset = CntPath;
% data0_ContinPreproc=ft_preprocessing(cfg);
% plot(data0_ContinPreproc.trial{1}(1, 22204:29203),'r')
% hold on ;
% plot(data1_ContinPreproc.trial{1}(1, 22204:29203),'g')
% plot(data2_ContinPreproc.trial{1}(1,:),'b');
% hold off;
figure;
cfg = [];
cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;
ft_databrowser(cfg,data1_ContinPreproc);

%%
%���ݷֶ�
cfg = [] ;

cfg.trl = trl ;

data2_TrialPreproc = ft_redefinetrial(cfg,data1_ContinPreproc);



%%
%��Ƶ�ݲ�
cfg = [];

%50Hz�ݲ��˲�
cfg.dftfilter = 'yes';
cfg.dftfreq = 50;
cfg.continuous = 'no';


data2_TrialPreproc = ft_preprocessing(cfg,data2_TrialPreproc);


cfg = [];
cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 7;
ft_databrowser(cfg,data2_TrialPreproc);

%%
%ICAȥ�۵�
cfg = [];

cfg.method = 'runica';
IcaComp = ft_componentanalysis(cfg,data2_TrialPreproc);

cfg.layout    = 'quickcap64.mat';
cfg.comment   = 'no';
cfg.component = 1:60;       % specify the component(s) that should be plotted
cfg.viewmode = 'component';

cfg.blocksize = 7;
ft_databrowser(cfg, IcaComp);

cfg = [];
cfg.component = 20; % to be removed component(s)
data3_ICA = ft_rejectcomponent(cfg, IcaComp,  data2_TrialPreproc);

cfg = [];

cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 7;

ft_databrowser(cfg,data3_ICA);



cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-1 ,0];
data4_Demean = ft_preprocessing(cfg,data3_ICA);

cfg = [];

cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 7;

ft_databrowser(cfg,data4_Demean);


% cfg = [];
% cfg.method = 'channel';
% ft_rejectvisual(cfg,data3_AfterDemean);
% 
% cfg.method = 'trial';
% ft_rejectvisual(cfg,data3_AfterDemean);
% 
% cfg.method ='summary';
% ft_rejectvisual(cfg,data3_AfterDemean);


cfg = [];

ERP  = ft_timelockanalysis(cfg, data4_Demean);

cfg.layout    = 'quickcap64.mat';
cfg.showlabels = 'yes';
cfg.showoutline = 'yes';
cfg.baseline = [-1,0];
cfg.baselinetype  = 'absolute';

ft_multiplotER(cfg, ERP);

cfg = [];
cfg.layout = 'quickcap64.mat';
cfg.baseline = [-1,0];
cfg.baselinetype  = 'absolute';
cfg.xlim = -1:1:6;
ft_topoplotER(cfg,ERP);


cfg = [];
cfg.output     = 'pow';
cfg.channel    = 'all';
cfg.method     = 'mtmconvol';
cfg.foi        = 2:2:50;
cfg.t_ftimwin  = 5./cfg.foi;
cfg.tapsmofrq  = 0.4 *cfg.foi;
cfg.toi        = -1:0.1:6;
TFRmult = ft_freqanalysis(cfg, data4_Demean);

cfg = [];
cfg.ylim  = [2 50];
cfg.baseline = [-1 0];  
cfg.baselinetype = 'absolute';	        
cfg.layout = 'quickcap64.mat';
cfg.showoutline = 'yes';

ft_multiplotTFR(cfg, TFRmult);

cfg = [];
cfg.xlim = [-1 0:0.5:3];
cfg.ylim  = [6 8];
cfg.baseline = [-1 0];  
cfg.baselinetype = 'absolute';	        
cfg.layout = 'quickcap64.mat';
cfg.showoutline = 'yes';

ft_topoplotTFR(cfg, TFRmult);

cfg = [];
cfg.xlim = -1:0.5:3;
cfg.ylim  = [10 15];
cfg.baseline = [-1 0];  
cfg.baselinetype = 'absolute';	             
cfg.layout = 'quickcap64.mat';
cfg.showoutline = 'yes';
figure;
ft_topoplotTFR(cfg, TFRmult);




 
