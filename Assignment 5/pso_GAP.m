clc; clear; close all;

% List of GAP files
numFiles = 12;
filePrefix = 'gap'; % Files are named gap1.txt, gap2.txt, ..., gap12.txt

% PSO Parameters
numParticles = 50;    % Swarm size
numIterations = 100;  % Maximum iterations
w = 0.7;              % Inertia weight
c1 = 1.5;             % Cognitive coefficient
c2 = 1.5;             % Social coefficient

% Store results for formatted output
results = cell(numFiles, 1);
headers = strings(1, numFiles);

% Open file to write results
outputFile = fopen('results_pso.txt', 'w');
fprintf(outputFile, 'InstanceID,Profit\n');

for fileIdx = 1:numFiles
    filename = sprintf('%s%d.txt', filePrefix, fileIdx);
    fileID = fopen(filename, 'r');
    
    if fileID == -1
        fprintf('Error: Unable to open %s\n', filename);
        continue;
    end
    
    % Read number of problems in the file
    numProblems = fscanf(fileID, '%d', 1);
    problemResults = strings(numProblems, 1);
    
    % Extract filename without extension for header
    [~, baseName, ~] = fileparts(filename);
    headers(fileIdx) = sprintf('%-20s', baseName); % Header formatting

    for p = 1:numProblems
        % Read problem parameters
        numServers = fscanf(fileID, '%d', 1);
        numUsers = fscanf(fileID, '%d', 1);
        
        % Read utility values
        U = fscanf(fileID, '%d', [numUsers, numServers])';
        
        % Read resource requirement matrix
        R = fscanf(fileID, '%d', [numUsers, numServers])';
        
        % Read server capacity
        capacity = fscanf(fileID, '%d', numServers);

        % Initialize PSO swarm
        position = rand(numParticles, numServers * numUsers); % Random initialization
        velocity = zeros(numParticles, numServers * numUsers);
        
        % Best positions & fitness values
        pBest = position;
        pBestFitness = -inf(numParticles, 1);
        [gBestFitness, gBestIdx] = max(pBestFitness);
        gBest = pBest(gBestIdx, :);

        % PSO Main Loop
        for iter = 1:numIterations
            fitness = zeros(numParticles, 1);
            
            for i = 1:numParticles
                % Convert continuous position values into binary assignment
                xBinary = reshape(position(i, :), numServers, numUsers);
                xBinary = (xBinary == max(xBinary)); % Assign user to the best server
                
                % Constraint check
                if all(sum(xBinary, 1) == 1) && all(all(sum(R .* xBinary, 2) <= capacity'))
                    fitness(i) = sum(sum(U .* xBinary)); % Valid solution, calculate utility
                else
                    fitness(i) = -inf; % Penalize infeasible solutions
                end
            end
            
            % Update personal & global bests
            betterIdx = fitness > pBestFitness;
            pBest(betterIdx, :) = position(betterIdx, :);
            pBestFitness(betterIdx) = fitness(betterIdx);
            
            [newGBestFitness, newGBestIdx] = max(pBestFitness);
            if newGBestFitness > gBestFitness
                gBestFitness = newGBestFitness;
                gBest = pBest(newGBestIdx, :);
            end

            % Update velocity & position
            velocity = w * velocity ...
                + c1 * rand(numParticles, numServers * numUsers) .* (pBest - position) ...
                + c2 * rand(numParticles, numServers * numUsers) .* (gBest - position);
            position = position + velocity;

            % Clamp positions between [0,1]
            position = max(0, min(1, position));
        end
        
        % Best solution for this problem instance
        bestAssignment = reshape(gBest, numServers, numUsers);
        bestAssignment = (bestAssignment == max(bestAssignment)); % Convert to valid binary form
        bestUtility = sum(sum(U .* bestAssignment));
        
        % Format output correctly with spacing
        problemID = sprintf('c%d%d-%d', numServers, numUsers, p);
        problemResults(p) = sprintf('%-12s %-6d', problemID, bestUtility);
        
        % Write to results_pso.txt
        fprintf(outputFile, '%s,%d\n', problemID, bestUtility);
    end
    
    results{fileIdx} = problemResults;
    fclose(fileID);
end

% Close the output file
fclose(outputFile);

% Print formatted output in groups of 4 files per row
colsPerRow = 4;
numRows = ceil(numFiles / colsPerRow);

for row = 1:numRows
    colStart = (row - 1) * colsPerRow + 1;
    colEnd = min(row * colsPerRow, numFiles);
    
    % Print headers
    fprintf('\n');
    for col = colStart:colEnd
        fprintf('%-22s', headers(col));
    end
    fprintf('\n');
    
    % Print problem results line by line
    maxProblems = max(cellfun(@numel, results(colStart:colEnd)));
    
    for p = 1:maxProblems
        for col = colStart:colEnd
            if p <= numel(results{col})
                fprintf('%-22s', results{col}(p));
            else
                fprintf('%-22s', ''); % Empty space for alignment
            end
        end
        fprintf('\n');
    end
end
