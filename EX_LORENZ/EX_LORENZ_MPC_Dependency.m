% LOTKA-VOLTERRA system
% System identification: DelayDMDc

clear all, close all, clc
addpath('../utils');

WORKING = 1;
SystemModel = 'LORENZ';
%% Parameters
InputSignalType = 'sphs';
ModelName = 'NARX'; % DMDc, NARX, SINDYc
TrainAlg = 'trainbr'; %trainlm,trainbr
select_model = ModelName;
dep_trainlength = 1;
dep_noise = 0;

% Ntrain_vec = [5:15,20:5:95,100:100:1000];%,1500:500:3000];
% eta_vec = 0;
% Nr = 1;

Ntrain_vec = [5:15,20:5:95,100:100:1000,1250,1500,2000,3000];
eta_vec = 0.05;
Nr = 1;


N_LENGTHS = length(Ntrain_vec);
Nmodels = N_LENGTHS;

%% Folders
if WORKING == 1
    figpath0 = ['/Users/ekaiser/Documents/Academia/Papers/KaKuBr_SINDYc-MPC/WORKING/FIGURES/EX_',SystemModel,'_Dependencies/'];
    datapath0 = ['/Users/ekaiser/Documents/Academia/Papers/KaKuBr_SINDYc-MPC/WORKING/DATA/EX_',SystemModel,'_Dependencies/'];
else
    figpath0 = ['../../FIGURES/EX_',SystemModel,'_Dependencies/'];
    datapath0 = ['../../DATA/EX_',SystemModel,'_Dependencies/'];
end

if strcmp(ModelName,'NARX')
    figpath = [figpath0, ModelName, '/',TrainAlg,'/TL/'];
    datapath = [datapath0, ModelName, '/',TrainAlg,'/TL/'];
else
    figpath = [figpath0, ModelName, '/TL/'];
    datapath = [datapath0, ModelName, '/TL/'];
end

mkdir(figpath)
mkdir(datapath)
%% Load all models
switch ModelName
    case 'DMDc'
        Models(1:Nmodels) = struct('name',[],'sys',[],'Ndelay', [], 'Ttraining', [],'dt',[], 'Err', [], 'ErrM', []);
    case 'SINDYc'
        Models(1:Nmodels) = struct('name',[],'polyorder',[],'usesine',[],'Xi',[],'dt',[],'N',[], 'Ttraining', [], 'Err', [], 'ErrM', []);
    case 'NARX'
        Models(1:Nmodels) = struct('name',[],'net',[],'stateDelays',[],'inputDelays',[], 'hiddenSizes', [], 'dt',[], 'Ttraining', [], 'Err', [], 'ErrM', []);
end

if eta_vec == 0
    for iModel = 1:Nmodels
        iN = iModel;
        load(fullfile(datapath,['EX_',SystemModel,'_SI_',ModelName,'_',InputSignalType,'_N',sprintf('%04g',Ntrain_vec(iN)), ...
            '_Eta',sprintf('%03g',100*eta_vec),'_iR1','.mat']))
        Models(iModel) = Model;
    end
elseif eta_vec~=0
    for iModel = 1:Nmodels
        iN = iModel;
        load(fullfile(datapath,['EX_',SystemModel,'_SI_',ModelName,'_',InputSignalType,'_N',sprintf('%04g',Ntrain_vec(iN)), ...
            '_Eta',sprintf('%03g',100*eta_vec),'_BEST_MODEL.mat']))
        Models(iModel) = Model;
    end
end

%% Run MPC for all models
runMPC

%% Save results
save(fullfile(datapath,['EX_',SystemModel,'_MPC_',ModelName,'_',InputSignalType,'_TrainLength','.mat']),'Results')

%%

figure,hold on
for iM = 1:Nmodels
    Jend = cumsum(Results(iM).J);
    plot(Ntrain_vec(iM),Jend(end),'ok')
end
set(gca,'xscale','log','yscale','log')
