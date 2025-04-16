clc; clear; close all;

% List of GAP files
numFiles = 12;
filePrefix = 'gap'; % Files are named gap1.txt, gap2.txt, ..., gap12.txt

% TLBO Parameters
numLearners = 50;      % Population size
numIterations = 100;   % Maximum iterations

% Store results for formatted output
results = cell(numFiles, 1);
headers = strings(1, numFiles);

% Open file to write results
outputFile = fopen('results_tlbo.txt', 'w');
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

        dim = numServers * numUsers;

        % Initialize learners (solutions)
        population = rand(numLearners, dim);
        fitness = -inf(numLearners, 1);

        % Evaluate initial fitness
        for i = 1:numLearners
            x = reshape(population(i, :), numServers, numUsers);
            xBinary = (x == max(x));
            if all(sum(xBinary, 1) == 1) && all(all(sum(R .* xBinary, 2) <= capacity'))
                fitness(i) = sum(sum(U .* xBinary));
            else
                fitness(i) = -inf;
            end
        end

        % TLBO Main Loop
        for iter = 1:numIterations
            % Teacher Phase
            [bestFitness, teacherIdx] = max(fitness);
            teacher = population(teacherIdx, :);
            meanLearner = mean(population);

            for i = 1:numLearners
                TF = randi([1, 2]); % Teaching factor either 1 or 2
                newSol = population(i, :) + rand(1, dim) .* (teacher - TF * meanLearner);

                % Clamp to [0, 1]
                newSol = max(0, min(1, newSol));

                % Evaluate new solution
                x = reshape(newSol, numServers, numUsers);
                xBinary = (x == max(x));
                if all(sum(xBinary, 1) == 1) && all(all(sum(R .* xBinary, 2) <= capacity'))
                    newFitness = sum(sum(U .* xBinary));
                else
                    newFitness = -inf;
                end

                if newFitness > fitness(i)
                    population(i, :) = newSol;
                    fitness(i) = newFitness;
                end
            end

            % Learner Phase
            for i = 1:numLearners
                partnerIdx = randi(numLearners);
                while partnerIdx == i
                    partnerIdx = randi(numLearners);
                end

                if fitness(i) > fitness(partnerIdx)
                    newSol = population(i, :) + rand(1, dim) .* (population(i, :) - population(partnerIdx, :));
                else
                    newSol = population(i, :) + rand(1, dim) .* (population(partnerIdx, :) - population(i, :));
                end

                % Clamp to [0, 1]
                newSol = max(0, min(1, newSol));

                % Evaluate new solution
                x = reshape(newSol, numServers, numUsers);
                xBinary = (x == max(x));
                if all(sum(xBinary, 1) == 1) && all(all(sum(R .* xBinary, 2) <= capacity'))
                    newFitness = sum(sum(U .* xBinary));
                else
                    newFitness = -inf;
                end

                if newFitness > fitness(i)
                    population(i, :) = newSol;
                    fitness(i) = newFitness;
                end
            end
        end

        % Best solution after TLBO
        [bestFitness, bestIdx] = max(fitness);
        bestAssignment = reshape(population(bestIdx, :), numServers, numUsers);
        bestAssignment = (bestAssignment == max(bestAssignment));
        bestUtility = sum(sum(U .* bestAssignment));
        
        % Format output correctly with spacing
        problemID = sprintf('c%d%d-%d', numServers, numUsers, p);
        problemResults(p) = sprintf('%-12s %-6d', problemID, bestUtility);
        
        % Write to results_tlbo.txt
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
