function finalAllocations = executeGAPCases()
    totalFiles = 12;
    finalAllocations = cell(1, totalFiles);
    formattedOutput = cell(totalFiles, 1);

    % Collect results to save
    allInstanceIDs = {};
    allProfits = [];

    for fileIndex = 1:totalFiles
        fileName = sprintf('gap%d.txt', fileIndex);
        fileID = fopen(fileName, 'r');
        if fileID == -1
            error('Cannot open file %s.', fileName);
        end
        
        numInstances = fscanf(fileID, '%d', 1);
        instanceResults = cell(numInstances, 1);
        
        for caseIndex = 1:numInstances
            numMachines = fscanf(fileID, '%d', 1);
            numTasks = fscanf(fileID, '%d', 1);
            
            profitMatrix = fscanf(fileID, '%d', [numTasks, numMachines])';
            demandMatrix = fscanf(fileID, '%d', [numTasks, numMachines])';
            
            capacityVector = fscanf(fileID, '%d', [numMachines, 1]);
            
            allocationMatrix = optimizeGAP(numMachines, numTasks, profitMatrix, demandMatrix, capacityVector);
            
            totalProfit = sum(sum(profitMatrix .* allocationMatrix));
            
            finalAllocations{fileIndex} = allocationMatrix;
            problemID = sprintf('c%d%d-%d', numMachines, numTasks, caseIndex);
            instanceResults{caseIndex} = sprintf('%s %d', problemID, totalProfit);
            
            % Store results for later saving
            allInstanceIDs{end+1} = problemID; %#ok<AGROW>
            allProfits(end+1) = totalProfit;   %#ok<AGROW>
        end
        
        formattedOutput{fileIndex} = instanceResults;
        fclose(fileID);
    end
    
    displayFormattedResults(formattedOutput, totalFiles);
    
    % Save results to .mat
    approx_results.instanceIDs = allInstanceIDs;
    approx_results.profits = allProfits;
    save('results_approx.mat', 'approx_results');

    % Optionally save as .txt
    T = table(allInstanceIDs', allProfits', 'VariableNames', {'InstanceID', 'Profit'});
    writetable(T, 'results_approx.txt');
end

function allocationMatrix = optimizeGAP(numMachines, numTasks, profitMatrix, demandMatrix, capacityVector)
    allocationMatrix = zeros(numMachines, numTasks);
    efficiencyScore = profitMatrix ./ (demandMatrix + 1e-6);
    [~, sortedIndices] = sort(efficiencyScore(:), 'ascend');
    remainingCapacity = capacityVector;
    
    for index = sortedIndices'
        [machine, task] = ind2sub([numMachines, numTasks], index);
        if remainingCapacity(machine) >= demandMatrix(machine, task)
            allocationMatrix(machine, task) = 1;
            remainingCapacity(machine) = remainingCapacity(machine) - demandMatrix(machine, task);
        end
    end
end

function displayFormattedResults(formattedOutput, totalFiles)
    filesPerRow = 4;
    maxInstances = max(cellfun(@length, formattedOutput));
    
    for startIdx = 1:filesPerRow:totalFiles
        endIdx = min(startIdx + filesPerRow - 1, totalFiles);
        
        for fileIdx = startIdx:endIdx
            fprintf('gap%d\t\t', fileIdx);
        end
        fprintf('\n');
        
        for caseIdx = 1:maxInstances
            for fileIdx = startIdx:endIdx
                if caseIdx <= length(formattedOutput{fileIdx})
                    fprintf('%s\t', formattedOutput{fileIdx}{caseIdx});
                else
                    fprintf('\t');
                end
            end
            fprintf('\n');
        end
        fprintf('\n');
    end
end

executeGAPCases();
