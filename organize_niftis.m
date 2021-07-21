
function organize_niftis(Path)
cd(Path);

files= dir([Path '/*']);
files = files(arrayfun(@(x) ~strcmp(x.name(1),'.'),files));

% We delete logfiles
logfiles = files(arrayfun(@(x) strcmp(x.name(1:3),'log'),files));
for i = 1:size(logfiles,1)
    delete([Path,logfiles(i).name]);
end

% We delete non-useful bvals and bvecs files (text files)
txtfiles = files(arrayfun(@(x) strcmp(x.name(end-2:end),'txt'),files));
for i = 1:size(txtfiles,1)
    if ~contains(txtfiles(i).name,'APA') && ~contains(txtfiles(i).name,'APP') && ~contains(txtfiles(i).name,'Nerfs')
        delete([Path,txtfiles(i).name]);
    end
end

% Now we organize and rename all remaining files
files= dir([Path '/*']);
files = files(arrayfun(@(x) ~strcmp(x.name(1),'.'),files));

for i = 1 : size(files,1)
    [~,~,ext]= fileparts(files(i).name);
    parts = strsplit(files(i).name,{'-','.'});
    subject = char(parts(1));
    sequence = char(parts(2));
    if strcmp(sequence,'DCE') || contains(sequence,'Nerfs')
        sequence = strcat(char(parts(2)),char(parts(3)));
    end
    
    if contains(parts(end-2),'bvals') || contains(parts(end-2),'bvecs')
        ext = strcat('.',char(parts(end-2)));
    end
    
    if exist(subject,'dir')~=7
        mkdir(subject);
    end
    
    movefile(fullfile(Path,files(i).name), fullfile(Path,subject,strcat(sequence,ext)));         
end


