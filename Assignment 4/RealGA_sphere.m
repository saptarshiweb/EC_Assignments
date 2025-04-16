function realGA_SBX_sphere()
    % Parameters
    nVars = 4;          % Number of variables
    popSize = 50;       % Population size
    maxGen = 100;       % Maximum generations
    pc = 0.8;           % Crossover probability
    pm = 0.1;           % Mutation probability
    eta_c = 15;         % SBX distribution index (typically 2-20)
    eta_m = 20;         % Polynomial mutation distribution index
    
    % Variable bounds
    lowerBound = -10 * ones(1, nVars);
    upperBound = 10 * ones(1, nVars);
    
    % Initialize population
    pop = repmat(lowerBound, popSize, 1) + ...
          repmat(upperBound - lowerBound, popSize, 1) .* rand(popSize, nVars);
    
    % Store best fitness and solution
    bestFitness = inf;
    bestSolution = zeros(1, nVars);
    fitnessHistory = zeros(maxGen, 1);
    
    % Main GA loop
    for gen = 1:maxGen
        % Evaluate fitness
        fitness = zeros(popSize, 1);
        for i = 1:popSize
            fitness(i) = sphereFunction(pop(i,:));
        end
        
        % Update best solution
        [minFit, idx] = min(fitness);
        if minFit < bestFitness
            bestFitness = minFit;
            bestSolution = pop(idx,:);
        end
        fitnessHistory(gen) = bestFitness;
        
        % Selection (Tournament selection)
        selectedIndices = tournamentSelection(fitness, popSize);
        selectedPop = pop(selectedIndices, :);
        
        % SBX Crossover
        offspring = sbxCrossover(selectedPop, pc, eta_c, lowerBound, upperBound);
        
        % Polynomial Mutation
        offspring = polynomialMutation(offspring, pm, eta_m, lowerBound, upperBound);
        
        % Elitism: Keep best individual
        [~, bestIdx] = min(fitness);
        offspring(1,:) = pop(bestIdx,:);
        
        % Update population
        pop = offspring;
        
        % Display progress
        if mod(gen, 10) == 0
            fprintf('Generation %d: Best fitness = %f\n', gen, bestFitness);
        end
    end
    
    % Results
    fprintf('\nOptimization completed:\n');
    fprintf('Best solution found: [%f, %f, %f, %f]\n', bestSolution);
    fprintf('Minimum function value: %f\n', bestFitness);
    
    % Plot fitness history
    figure;
    plot(1:maxGen, fitnessHistory, 'LineWidth', 2);
    xlabel('Generation');
    ylabel('Best Fitness');
    title('Convergence of Real-Coded GA with SBX on Sphere Function');
    grid on;
end

% Sphere function
function f = sphereFunction(x)
    f = sum(x.^2);
end

% Tournament selection
function selectedIndices = tournamentSelection(fitness, popSize)
    selectedIndices = zeros(popSize, 1);
    tournamentSize = 2; % Tournament size
    
    for i = 1:popSize
        % Randomly select tournamentSize individuals
        contestants = randperm(popSize, tournamentSize);
        [~, bestIdx] = min(fitness(contestants));
        selectedIndices(i) = contestants(bestIdx);
    end
end

% Simulated Binary Crossover (SBX)
function offspring = sbxCrossover(parents, pc, eta_c, lowerBound, upperBound)
    [popSize, nVars] = size(parents);
    offspring = parents;
    
    for i = 1:2:popSize-1
        if rand < pc
            parent1 = parents(i,:);
            parent2 = parents(i+1,:);
            child1 = zeros(1, nVars);
            child2 = zeros(1, nVars);
            
            for j = 1:nVars
                if rand <= 0.5
                    % Ensure parents are ordered
                    if abs(parent1(j) - parent2(j)) > 1e-10
                        if parent1(j) < parent2(j)
                            x1 = parent1(j);
                            x2 = parent2(j);
                        else
                            x1 = parent2(j);
                            x2 = parent1(j);
                        end
                        
                        % Calculate beta
                        u = rand;
                        if u <= 0.5
                            beta = (2*u)^(1/(eta_c+1));
                        else
                            beta = (1/(2*(1-u)))^(1/(eta_c+1));
                        end
                        
                        % Create children
                        child1(j) = 0.5 * ((x1 + x2) - beta*(x2 - x1));
                        child2(j) = 0.5 * ((x1 + x2) + beta*(x2 - x1));
                        
                        % Ensure children are within bounds
                        child1(j) = max(min(child1(j), upperBound(j)), lowerBound(j));
                        child2(j) = max(min(child2(j), upperBound(j)), lowerBound(j));
                    else
                        child1(j) = parent1(j);
                        child2(j) = parent2(j);
                    end
                else
                    child1(j) = parent1(j);
                    child2(j) = parent2(j);
                end
            end
            
            offspring(i,:) = child1;
            offspring(i+1,:) = child2;
        end
    end
end

% Polynomial Mutation
function offspring = polynomialMutation(offspring, pm, eta_m, lowerBound, upperBound)
    [popSize, nVars] = size(offspring);
    
    for i = 1:popSize
        for j = 1:nVars
            if rand < pm
                y = offspring(i,j);
                yl = lowerBound(j);
                yu = upperBound(j);
                delta1 = (y - yl) / (yu - yl);
                delta2 = (yu - y) / (yu - yl);
                r = rand;
                
                if r <= 0.5
                    deltaq = (2*r + (1-2*r)*(1-delta1)^(eta_m+1))^(1/(eta_m+1)) - 1;
                else
                    deltaq = 1 - (2*(1-r) + 2*(r-0.5)*(1-delta2)^(eta_m+1))^(1/(eta_m+1));
                end
                
                y = y + deltaq * (yu - yl);
                y = min(max(y, yl), yu);
                offspring(i,j) = y;
            end
        end
    end
end