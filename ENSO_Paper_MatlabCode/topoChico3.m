%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notes:
% topoChico3 will loop through different depth levels 
% to produce .nc and .txt files compatible with our 
% Python code.
%
% Observations:
% Modify Nino3.4 region accordingly to see
% if we can obtain better results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

depth_Vec = 105:10:205;
for NN = 1:length(depth_Vec)
    depth_level = depth_Vec(NN);
    topoChico2(depth_level);
end
%%
depth_Vec = 5;
topoChico2(5);
