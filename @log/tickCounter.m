function [ counter, L ] = tickCounter( L )
%TICKCOUNTER Increase counter and return.

L.counter = L.counter + 1;

counter = L.counter;

