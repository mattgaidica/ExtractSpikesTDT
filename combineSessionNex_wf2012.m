function combineSessionNex_wf2012( varargin )
%
% usage: combineSessionNex( varargin )
%
% INPUTS:
%
% varargins:
%   if no input arguments given, then the function will give a dialog box
%   and ask for a "parent" directory in which to scan. Otherwise, the only
%   input argument should be the name of the parent directory.
%
% OTHER CUSTOM SCRIPTS/FUNCTIONS REQUIRED:
%   combineNex_wf2012 - takes multiple .nex files and combines them into one .nex
%       structure, renaming the units to fit the workflow
%   writeNexFile - takes a .nex data structure and writes it to disk in
%       .nex format

if nargin == 0
    % no parent directory selected; to be filled out later
    parentDir = uigetdir();
    if isequal(parentDir, 0)
        disp('No parent directory selected.');
        return;
    end
else
    parentDir = varargin{1};
end

if ~exist(parentDir,'dir')
    disp('no such directory');
    return;
end

cd(parentDir)

temp = dir;
numNames = length(temp);

dirCount = 0;
excludeDirs = {'.','..','.DS_Store'};
for iDir = 1 : numNames
    if any(strcmpi(temp(iDir).name, excludeDirs)) || ~isdir(temp(iDir).name)
        continue;
    end
    dirCount = dirCount + 1;
    subdirs{dirCount} = temp(iDir).name;
end

numDirs = length(subdirs);

for iDir = 1 : numDirs
    
    cd(fullfile(parentDir, subdirs{iDir}));
    
    nexList = dir('*.nex');
    
    numNex = length(nexList);
    if numNex <= 1; continue; end
    
    nexNames = cell(1, numNex);
    for iNex = 1 : numNex
        nexNames{iNex} = nexList(iNex).name;
    end
    
    % using the PLX file for Fs, this is upsampled (48828)
    plxName = dir('*.plx');
    if isempty(plxName); continue; end
    [~, ~, Fs, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = plx_information(plxName(1).name);
    
    combinedNex = combineNex_wf2012(nexNames, Fs, subdirs{iDir});

    
    combinedNexName = [subdirs{iDir} '.nex'];
    finishedDirName = [subdirs{iDir} '_finished'];
    if ~exist(finishedDirName,'dir')
        mkdir(finishedDirName);
    end
    
    result = writeNexFile(combinedNex, fullfile(parentDir, subdirs{iDir}, finishedDirName, combinedNexName));
    
    if result
        disp([combinedNexName ' successfully saved.']);
    else
        disp(['error saving ' combinedNexName]);
    end
    
end