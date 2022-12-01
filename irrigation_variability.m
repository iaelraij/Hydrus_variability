% path to the folder where the basic simulation is stored
folder=pwd; % in this case is there matlab code is in the same folder as Hydrus projects
%% sample fluxes with a chosen mean and CV using the Latin hypercube technique 
% number of simulations 
N=200;
irrF=[];
mean=20; %this is the mean dripper flux as defined by the manufacturer, in the specific units of your simulation.
CV=0.02; % coefficient of variation of the dripper discharge. In this case we run simulatinos with 0.02, 0.04 and 0.09
stdev=mean*CV;
%sample fluxes with a chosen mean and CV using the Latin hypercube
%technique, assuming a normal distribution.
X = lhsnorm(mean,stdev,N);

%% set up and run simulations 
% make sure the project has a permanent working directory
% Unselect "press enter at the end" on the Output Information window
% set output at fixed times (every hour or every day is suggested)
BasicFile='drip_3D_axi_v2'; % this is your *.h3d2 file
% run loops of simulations
% this loop will create as many Hydrus files as simulations were indicated
% in the N variable, update the dircharge rate, run, read results and save
% the results. The code can be edited to use just one proejct file instead
% of saving each one.
for i=1:N
    display(i)
    c = newline;
    %creating a new Hydrus file
    copyfile([folder '\H3D2_' BasicFile],[folder '\H3D2_' BasicFile '_' num2str(i)])
   copyfile([folder '\' BasicFile '.h3d2'],[folder '\' BasicFile '_' num2str(i) '.h3d2'])
    fid = fopen([folder '\H3D2_' BasicFile '_' num2str(i) '\ATMOSPH.in'], 'r');
j = 1;
lines{j} = fgets(fid);
while ischar(lines{j})
    j = j + 1;
    lines{j} = fgets(fid);
end
fclose(fid);
% The following lines read the Atmosph.in file and re-write it using the
% new discharge rate according to the defined distribution.
    %the user needs to set ind to be at the line in the file where the
    %irrigation event happens
   ind = 8; % this number might need to be updated for different simulations
        v2= lines{ind};
        v = str2num(lines{ind});
        v(6)=-X(i);
        str=num2str(v);
        ni= strjoin({str,c});
        lines{ind}=ni;
     ind = 10; 
        v2= lines{ind};
        v = str2num(lines{ind});
        v(6)=-X(i); %choosing the i value in the vector of discharge rate distribution
        str=num2str(v);
        ni= strjoin({str,c});
        lines{ind}=ni; 
        
        %re-write ATMOSPH.in
    fid = fopen([folder '\H3D2_' BasicFile '_' num2str(i) '\ATMOSPH.in'], 'w')
    for ind = 1:(size(lines,2)-1)
        fprintf(fid, lines{ind});
    end
    fclose(fid);
    
    %run simulation
    % the user needs to create a text file named level_01.dir and save it in the working folder. The Matlab code will write the name of each simulation to be run in each iteration.
    [level01,message]=fopen([folder '\level_01.dir'],'w');
     fwrite(level01,[folder '\H3D2_' BasicFile '_' num2str(i)]);
    fclose(level01);
    cd(folder)
    % the Hydrus executable file can be saved in the working folder or the next line can be directed to where the exe file is saved.
    [status,res]=dos([folder '\H2D_CALC.EXE']);
    
    %save results in the total structure
    fileN=[BasicFile '_' num2str(i)];
    % the results function saves the Hydrus outputs into the Matlab
    % workspace. The user needs to download the results function and add it
    % to the path.
    [v_mean,cumQ,obsN,atmosph,fileN]=results(['H3D2_' fileN], folder) ;
    ResultsSim(i).file=fileN;
    ResultsSim(i).vM=v_mean;
    ResultsSim(i).cQ=cumQ;
    ResultsSim(i).obsN=obsN;
    ResultsSim(i).Atm=atmosph;
    save('ResultsSim')
end
%%
save('ResultsSim')

