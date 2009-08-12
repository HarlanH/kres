function [ K ] = resetACoherence( K )
%RESETACOHERENCE Reset accumulated coherence integrator.

K.ACoherence = 0;
