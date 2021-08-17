%% Draft

%% Open a channel to the cni Flywheel instaqnce
cni = scitran('cni');

%% Get the QA project information
%{
qaProject = cni.lookup('cni/qa');

% This gets a partial download of the session information.  To get the full
% download
qaSessions = qaProject.sessions();

%%
id = qaSessions{end-12}.id;
thisSession = cni.fw.get(id);

an = thisSession.analyses();

thisA = cni.fw.get('60f7348b20c8ff1669df479f');

qaFiles = thisA.files;
stPrint(qaFiles,'name')
qaFiles{8}.download('thisresult.json');
result = jsonread('thisresult.json');
%}
%% The logical flow

qaProject = cni.lookup('cni/qa');

% How to get a single, full project by search.
%  tmp = cni.search('project','project label exact','qa','container',true);
%  qaProject = tmp{1};

% Find the sessions created after a certain date.
qaSessions = qaProject.sessions.find('created>2021-07-15');

%% Could we search for qa project sessions with a recent date?

% I guess so!  We must 'fw' true it takes a lot longer but we get back
% everything.  If we do not, then we get a good summary.  Might be enough.
%{
qaSessions = cni.search('session',...
    'project label exact','qa',...
    'session after time','now-26w',...
    'container',true);
size(qaSessions)
%}

%%  For each session, we can find the acquisitions and analyses this way

% We will loop on these to get all the snr and sfnr data
% ss = 12;
% qaAcq = qaSessions{ss}.acquisitions();
% stPrint(qaAcq,'label');

% qaAnalyses = qaSessions{ss}.analyses();
% stPrint(qaAnalyses,'label');

%% Find all the analyses with a 'cni-tsnr' in the label
qq = 1;
clear qaData
for ss=1:numel(qaSessions)
    
    qaAnalyses = qaSessions{ss}.analyses();
    if isempty(qaAnalyses), break; end
    qaAnalyses = stSelect(qaAnalyses,'label','cni-tsnr');
    if ~isempty(qaAnalyses)
        for aa = 1:numel(qaAnalyses)
            % Find the result file
            thisFile = stSelect(qaAnalyses{aa}.files,'name','result');
            if isempty(thisFile)
                fprintf('No result.json file found\n');
                stPrint(qaAnalyses{aa}.files,'name');
            else
                fprintf('Analyses with a result file found in session %d\n',ss);

                % Download the file and read its contents
                thisFile{1}.download('result.json');
                tmp = jsonread('result.json');
                tmp.created = qaAnalyses{aa}.created;
                
                %% Find which acquisition has the input file from the analyses
                
                % The acquisition label should be the same when we plot the snr or sfnr.
                fileid = qaAnalyses{aa}.inputs{1}.id;
                thisAcq = cni.search('acquisition','fileid',fileid,'container',true);
                tmp.acquisition =  thisAcq{1}.label;
                qaData{qq} = tmp; %#ok<SAGROW>
                qq = qq+1;
            end
        end
    end
    
end

%% Now we could pull out the variables we want
%
% Say we want the snr for all the acquisitions with a label
% or the sfnr.
acqNames = {'BOLD EPI Ax','Ax EPI'};
stPrint(qaData,'acquisition');

acq1 = stSelect(qaData,'acquisition',acqNames{1});
acq2 = stSelect(qaData,'acquisition',acqNames{2});

str2double(acq1{1}.sfnr_center)
str2double(acq1{1}.tsnr_center)

str2double(acq2{1}.sfnr_center)
str2double(acq2{1}.tsnr_center)

%% This would be all sessions in the project.

% qaSessions = qaProject.sessions();


%% END