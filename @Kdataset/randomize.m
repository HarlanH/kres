function [ DS ] = randomize( DS )
%RANDOMIZE Randomize the order of a dataset


ordering = randperm(size(DS.data,1));
DS.data = DS.data(ordering, :);
