function model = CreateModel(Items,BinSize)
% Items
model.v = Items;
% Number of items
model.n = numel(model.v);
% Bin size
model.Vmax = BinSize;
end