%%%%% modify in Rpredict.py the model we want to run (2, 3, 4- texture or
%%%%% texture+bd, etc%%%%
%%%% modify the textscan to match the amount of inputs per line, according
%%%% to the data and the model to be used.

%         # UNITS!
%         # SSC in weight %
%         # BD in g/cm3
%         # TH33 and T1500 as cm3/cm3
% 
%         # OUTPUT
%         # theta_r [cm3/cm3]
%         # theta_s [cm3/cm3]
%         # alpha  [1/cm]
%         # n
%         # Ks in [cm/day]
%         # standard deviations apply to the log10 forms for alpha, n and KS
%         # NOT their their antilog forms 
%% define the data and run Rosetta3 
% folder where the data is
folder=pwd;
% folder where the Rosetta3 Python codes are stored
folderR='D:\Rosetta-3.0beta';
% folder where Python is stored in the computer
folderPy='C:\Python27\pythonNew\python.exe';
% name of the data file and desired output files
nameI=['texture_HydrusReview.txt'];
nameO1=['output1_HydrusReview.txt'];
nameO2=['output2_HydrusReview.txt'];
%run with python
dos([folderPy ' ' folderR '\Rpredict.py -i ' folder '\' nameI ' -o ' folder '\' nameO1 ' -o2 ' folder '\' nameO2 ' --predict --sqlite=' folderR '\sqlite\Rosetta.sqlite']) 
% the formatSpec1 needs to be adjusted according to the specific model run in
% Rosetta3
formatSpec1 = '%f%f%f%f%f%[^\n\r]';
delimiter = ',';
%% read outputs and bring the data into the Matlab Worskpace
% read output 1
o1=fopen([folder '\' nameO1],'r');
dataArray = textscan(o1, formatSpec1, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(o1);
output1=[dataArray{1:end-1}];
%read output 2
formatSpec2 = '%f%f%f%f%f%f%f%[^\n\r]';
o2=fopen([folder '\' nameO2],'r');
dataArray = textscan(o2, formatSpec1, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(o2);
output2=[dataArray{1:end-1}];
%% if we already run Rosetta and don't want to run it again:
folder=pwd;
load('D:\HYDRUS\Review\ResultsSim.mat','output1','output2')

%% sample chosen parameters using the Latin hypercube technique 
% number of simulations 
N=200;
soilN=1;
Ks_cmdayN=[];
figure
for i=1:size(output1,1)
X = lhsnorm(log10(output1(i,5)),output2(i,5),N)';
Ks_cmday=10.^X;
if i<11
subplot(2,5,i)
histogram(X,20)
end
Ks_cmdayN(i,:)=Ks_cmday;
end
close all
%% set up simulations
% make sure the project has a permanent working directory
% Unselect "press enter at the end" on the Output Information window
% set output at fixed times (every hour or every day is suggested)
BasicFile='drip_3D_axi_v2';
folder= pwd;
units=24;%1 hours, 24 is day
if units==1
    Ks=Ks_cmdayN./24;
else
    Ks=Ks_cmdayN;
end
%% run loops of simulations
for i=1:N
    display(i)
    c = newline;
    copyfile([folder '\H3D2_' BasicFile],[folder '\H3D2_' BasicFile '_' num2str(i)])
   copyfile([folder '\' BasicFile '.h3d2'],[folder '\' BasicFile '_' num2str(i) '.h3d2'])
    fid = fopen([folder '\H3D2_' BasicFile '_' num2str(i) '\SELECTOR.in'], 'r');
j = 1;
lines{j} = fgets(fid);
while ischar(lines{j})
    j = j + 1;
    lines{j} = fgets(fid);
end
fclose(fid);
    %the user needs to set ind to be at the line in the file where the
    %hydraulic properties are
   ind = 25; 
        v2= lines{ind};
        hydPC=strsplit(v2,' ');
        nn=[output1(soilN,1:4),Ks(soilN,i)]; %when only the Ks is being changed with each simulation
        str=num2str([nn(ind-24,:),0.5]);
        ni= strjoin({str,c});
        lines{ind}=ni;
   
    %re-write selector.in
    fid = fopen([folder '\H3D2_' BasicFile '_' num2str(i) '\SELECTOR.in'], 'w')
    for ind = 1:(size(lines,2)-1)
        fprintf(fid, lines{ind});
    end
    fclose(fid);
    
    %run simulation
    [level01,message]=fopen([folder '\level_01.dir'],'w');
     fwrite(level01,[folder '\H3D2_' BasicFile '_' num2str(i)]);
    fclose(level01);
    cd(folder)
    [status,res]=dos([folder '\H2D_CALC.EXE'])
    
    %save results in the total structure
    fileN=[BasicFile '_' num2str(i)];
    % the results function saves the Hydrus outputs into the Matlab
    % workspace
    [v_mean,cumQ,obsN,atmosph,fileN]=results(['H3D2_' fileN], folder) ;
    ResultsSim(i).file=fileN;
    ResultsSim(i).vM=v_mean;
    ResultsSim(i).cQ=cumQ;
    ResultsSim(i).obsN=obsN;
    ResultsSim(i).Atm=atmosph;
    save('ResultsSim')
end
 ResultsSoil_1_Ks200=ResultsSim;
save('ResultsSoil_1_Ks200','ResultsSoil_1_Ks200')

