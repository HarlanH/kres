function [ K ] = train( K, Xin, Xout, P )
%TRAIN Train a KRES network on a single example.
%   K - the network
%   Xin - the example, input
%   Xout - the example, target
%   P - parameters

if (nargin ~= 4),
    error('KRES:kres:train', 'Not enough arguments!');
end

% Internal parameter for running exemplar stuff first or second.
exemplarTiming = 1; % 0 for first (@@@broken!!!), 1 for between - and +, 2 for finally

if (exemplarTiming == 0),
    doExemplarStuff;
end

% OK! Here's how this will work. First, converge with just Xin as input,
% and save the activations. Then, converge with Xin+Xout as input, and save
% the activations. Then, update the weights.

[K.minusAct, K.log.SettleTime] = converge(K, Xin, P);

if (exemplarTiming == 1),
    doExemplarStuff;
end

K.plusAct = converge(K, Xin+Xout, P); % ignore this settle time

% now, figure out the weight changes
dw = K.wCHL .* getLearningRate(P) .* (K.plusAct' * K.plusAct - K.minusAct' * K.minusAct);
% and update the weights
K.w = K.w + dw;
% and do logging
K.log.DW = sum(sum(abs(dw)));

% Now, figure out the ensemble's prediction and error. 

% Use the node tree in K to get the output nodes. Use those to figure out
% which elements of K.minusAct belong in the output vector.
% Then, do LCR on that.
% Also, get the target values for SSE calculation later.

outList = tree2leaves(subtree(K.nodeTree, 'O'));
outAct = zeros(size(outList));
targetAct = zeros(size(outList));
for i = 1:length(outAct),
    idx = getNodeIdx(K, outList(i));
    outAct(i) = K.minusAct(idx);
    targetAct(i) = Xout(idx)/2 + .5;  % Xout is -1/1, but we need 0/1
end

K.log.Outputs = outAct ./ sum(outAct);

% calculate SSE 
% this is a comparison between outAct and targetAct
K.log.SSE = sum((K.log.Outputs - targetAct) .^ 2);	% use scaled outputs!
K.log.ASSE = K.log.ASSE + K.log.SSE;

% and for logging...
K.log.Input = Xin + Xout;

if (exemplarTiming == 2),
    doExemplarStuff;
end



    function doExemplarStuff()
        % OK, now, if there are exemplar nodes, deal with them, which
        % includes checking for matches and possibly recruiting more exemplar nodes.
        if ~isempty(K.exempNodeIdxs),
            % check for an exemplar match. Does Xin match any exemplar
            % weights?
            
            XinW = Xin .* getExempLearningRate(P); % what would be stored if it were here
            KwMasked = K.w .* K.exempExemp;
            
            % now, does XinNorm match any rows of KwMasked?
            % I think if you do a matrix multiply, you'll get a column of
            % numbers that represent matches. Any that are equal to the
            % norm of XinW should indicate a match. Or something like that.
            XinW2 = sum(XinW .^ 2);
            matches = (KwMasked * XinW') ./ XinW2;
            
            % old code for non-veridical exemplars.

%             % compare input activations (minus phase) to K.w
%             % first, mask the minus phase acts with the exemplar connections
%             exempInputActs = K.minusAct .* K.exempExemp(K.exempNodeIdxs(1),:);
%             % now, normalize and make into a square matrix
%             exempInputActsNorm = exempInputActs ./ sum(abs(exempInputActs));
%             exempInputActsSq = repmat(exempInputActsNorm', 1, length(exempInputActsNorm));
%             
%             % this is the same thing, but with inputs, not activations
%             Xin1 = Xin ./ sum(abs(Xin));                    % normalize
%             Xin2 = repmat(Xin1', 1, length(Xin1));      % make square matrix
%             % we only care about connections to exemplar nodes, so mask Kw
%             Kwmasked = K.w .* K.exempExemp;
%             Kw1 = Kwmasked ./ repmat(sum(abs(Kwmasked)) + .000001, length(exempInputActsNorm), 1);
%                                                         % normalize by columns
%             matchIdxs = find(sum(abs(Xin2 - Kw1)) < getExempCriterion(P), 1);


            % if yes, there's a match
            if (any(matches > .99)),
                % This was old code for non-veridical exemplars. Now, do nothing!
                
                % just update the exemp weights
        %         ourIdx = matchIdxs(1);
        %         factor = (sum(abs(Xin)) ./ sum(abs(Kwmasked(:,ourIdx)))) .^ ...
        %             getExempLearningRate(P);
        %         K.w(ourIdx,:) = K.w(ourIdx,:) .* factor;
        %         K.w(:,ourIdx) = K.w(ourIdx,:)';
            else
                % otherwise, recruit a new exemplar (if available)
                if (K.exempActivated < length(K.exempNodeIdxs)),
                    % setting the CHL and exemp weights.

                    K.exempActivated = K.exempActivated + 1;
                    ourIdx = K.exempNodeIdxs(K.exempActivated); % shorthand

                    % for CHL weights, just copy the appropriate row/column into
                    % the weight matrix, then set wCHL so they can be updated.
                    K.w(:,ourIdx) = K.w(:,ourIdx) + K.exempCHL(:,ourIdx);
                    K.w(ourIdx,:) = K.w(ourIdx,:) + K.exempCHL(ourIdx,:);
                    % yep, that seems to work... now the wCHL
                    K.wCHL(:,ourIdx) = K.wCHL(:,ourIdx) + (K.exempCHL(:,ourIdx) ~= 0);
                    K.wCHL(ourIdx,:) = K.wCHL(ourIdx,:) + (K.exempCHL(ourIdx,:) ~= 0);

                    % for exemp weights, use the param to set those weights to be a
                    % scaled, transformed version of Xin. 
                    K.w(ourIdx,:) = K.w(ourIdx,:) + getExempLearningRate(P) * ...
                        Xin;
                        %(1./(1+exp(-Xin))); for use with activations
                    K.w(:,ourIdx) = K.w(ourIdx,:)';

                    % 
                else
                    bestexemp = min(sum(abs(Xin2 - Kw1)));
                    warning('KRES:kres:train', 'We have run out of recruitable exemplars! Best distance = %0.3f\n', bestexemp);
                end
            end
        end
    end % doExemplarStuff

end % train function
