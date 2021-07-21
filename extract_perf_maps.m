function extract_perf_maps(Path,file,nproc)

Subj_dir = dir([Path '/*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
C3Dcommand='/home/veronica/Downloads/Programs/c3d/bin/c3d';

for i = 1 : size(Subj_dir,1)
    disp(Subj_dir(i,1).name);

end
end