function [ L ] = getLength( DS )
%GETLENGTH Return number of items in the dataset.

L = size(DS.data, 1);

