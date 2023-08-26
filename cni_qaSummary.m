%% Draft

%% Open a channel to the cni Flywheel instance

cni = scitran('cni');
qaProject = cni.lookup('cni/qa');

% Find the sessions created after a certain date.
qaSessions = qaProject.sessions.find('created>2021-03-15');
fprintf('Found %d sessions\n',numel(qaSessions));

%% Find all the analyses with a 'cni-tsnr' in the label
qq = 1;
clear qaData
for ss=1:numel(qaSessions)
    
    % Get the analyses
    qaAnalyses = qaSessions{ss}.analyses();
    if ~isempty(qaAnalyses)
        
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
                    
                    % Find which acquisition has the input file from
                    % the analyses. The acquisition label should be
                    % the same when we plot the snr or sfnr. 

                    % This is the id of a file.  We want to find which
                    % acquisition contains this file.
                    
                    % This is the analysis
                    % qaAnalyses{aa}.inputs{1}.parentRef 

                    % The acquisition is empty in this case.
                    % qaAnalyses{aa}.inputs{1}.parents

                    % This is the fileId.  How can we find it and the
                    % acquisition that contains it?  Use lookup?
                    %
                    % To find the acquisition, we can get session for
                    % the analysis this way where the ID is the
                    % session id
                    %
                    % theSession = cni.fw.sessions.findOne('_id=604f89af9cf87cf7bb3da252')
                    % Loop through the acqusitions to find the file
                    %
                    % acquisitions = cni.fw.acquisitions.find('session=sessionID')
                    % Ver 17 will have cni.fw.files.find and
                    %                  cni.fw.analyes.find
                    fileid = qaAnalyses{aa}.inputs{1}.fileId;
                    thisAcq = cni.search('acquisition','fileid',fileid,'container',true);
                    if ~isempty(thisAcq)
                        tmp.acquisition =  thisAcq{1}.label;
                    else
                        fprintf('No acquisition found for input file on analysis %d\n',aa);
                        tmp.acquisition = 'Unknown acq';
                    end
                    qaData{qq} = tmp; %#ok<SAGROW>
                    qq = qq+1;
                end
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

%%
clear s t d
mrvNewGraphWin;
for ii=1:numel(acq1)
    s(ii) = str2double(acq1{ii}.sfnr_center);
    d(ii) = acq1{ii}.created;
end
plot(d,s,'LineWidth',2)
grid on
title(acqNames{1});

%%
clear s t d
mrvNewGraphWin;
for ii=1:numel(acq2)
    s(ii) = str2double(acq2{ii}.sfnr_center);
    % t(ii) = str2double(acq2{ii}.tsnr_center);
    d(ii) = acq2{ii}.created;
end
plot(d,s,'LineWidth',2)
title(acqNames{2});
grid on

%% This would be all sessions in the project.

% qaSessions = qaProject.sessions();

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

%% END