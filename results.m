function [v_mean,cumQ,obsN,atmosph,file]=results(file, folder)

fname=[folder '\' file];
%% water flow
%Column legend: 3-potential RWU, 5-actual RWU in cm/d
%6-irrigation, 10-drainage in cm^2/day
%2-4 potential and actual Precipitation and evaporation
fid = fopen([fname '\v_mean.out'], 'r');
i = 1;
lines{i} = fgets(fid);
while ischar(lines{i})
    i = i + 1;
    lines{i} = fgets(fid);
end
fclose(fid);
v_mean = [];
for ind = 14 : i-2
    v = str2num(lines{ind});
    v_mean = cat(1,v_mean,v);
end
%%  cumulative water fluxes in cm^2
%Column legend: 3-potential RWU, 5-actual RWU, 6-irrigation, 10-drainage
fid = fopen([fname '\cum_Q.out'], 'r');
i = 1;
lines{i} = fgets(fid);
while ischar(lines{i})
    i = i + 1;
    lines{i} = fgets(fid);
end
fclose(fid);
cumQ=[];
for ind = 14 : i-2
    v = str2num(lines{ind});
    cumQ = cat(1,cumQ,v);
end
%% obsNod
    fid = fopen([fname '\ObsNod.out'], 'r');
    i = 1;
    lines{i} = fgets(fid);
    while ischar(lines{i})
        i = i + 1;
        lines{i} = fgets(fid);
    end
    fclose(fid);
    obsN=[];
    for ind = 7 : i-2
        v = str2num(lines{ind});
        obsN = cat(1,obsN,v);
    end
    
%    %% balance
%     fid = fopen([fname '\Balance.out'], 'r');
%     i = 1;
%     lines{i} = fgets(fid);
%     while ischar(lines{i})
%         i = i + 1;
%         lines{i} = fgets(fid);
%     end
%     fclose(fid);
%     balance = [];
% %if there are no solutes then
% for ind = 32:14:2006
%     v = lines{ind};
%     v1=str2num(v(21:32));
%     balance = cat(1,balance,v1);
% end
    %% Time variable boundary conditions - atmosph.in
    fid = fopen([fname '\atmosph.in'], 'r');
i = 1;
lines{i} = fgets(fid);
while ischar(lines{i})
    i = i + 1;
    lines{i} = fgets(fid);
end
fclose(fid);
atmosph = [];
for ind = 7 : i-2
    v = str2num(lines{ind});
    atmosph = cat(1,atmosph,v);
end

%% 
save(['Results' file])
    
end
