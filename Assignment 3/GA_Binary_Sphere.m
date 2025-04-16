function binaryGA_sphere()
    % Parameters
    nVars = 4;          % Number of variables
    popSize = 50;        % Population size
    maxGen = 100;        % Maximum generations
    pc = 0.8;           % Crossover probability
    pm = 0.01;          % Mutation probability per bit
    bitLength = 20;     % Bits per variable
    totalBits = nVars * bitLength; % Total bits in chromosome
    
    % Initialize population
    pop = randi([0 1], popSize, totalBits);
    
    % Store best fitness and solution
    bestFitness = inf;
    bestSolution = zeros(1, nVars);
    fitnessHistory = zeros(maxGen, 1);
    
    % Main GA loop
    for gen = 1:maxGen
        % Decode and evaluate fitness
        fitness = zeros(popSize, 1);
        solutions = zeros(popSize, nVars);
        
        for i = 1:popSize
            solutions(i,:) = decodeChromosome(pop(i,:), nVars, bitLength, -10, 10);
            fitness(i) = sphereFunction(solutions(i,:));
        end
        
        % Update best solution
        [minFit, idx] = min(fitness);
        if minFit < bestFitness
            bestFitness = minFit;
            bestSolution = solutions(idx,:);
        end
        fitnessHistory(gen) = bestFitness;
        
        % Selection (Tournament selection)
        selected = tournamentSelection(pop, fitness, popSize);
        
        % Crossover (Single-point crossover)
        offspring = crossover(selected, pc, popSize, totalBits);
        
        % Mutation (Bit-flip mutation)
        offspring = mutation(offspring, pm);
        
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
    title('Convergence of Binary GA on Sphere Function');
    grid on;
end

% Decode binary chromosome to real values
function vars = decodeChromosome(chromosome, nVars, bitLength, minVal, maxVal)
    vars = zeros(1, nVars);
    for i = 1:nVars
        startBit = (i-1)*bitLength + 1;
        endBit = i*bitLength;
        gene = chromosome(startBit:endBit);
        
        % Convert binary to decimal
        dec = 0;
        for j = 1:bitLength
            dec = dec + gene(j) * 2^(bitLength-j);
        end
        
        % Map to [minVal, maxVal]
        vars(i) = minVal + (maxVal - minVal) * dec / (2^bitLength - 1);
    end
end

% Sphere function
function f = sphereFunction(x)
    f = sum(x.^2);
end

% Tournament selection
function selected = tournamentSelection(pop, fitness, popSize)
    selected = zeros(size(pop));
    tournamentSize = 2; % Tournament size
    
    for i = 1:popSize
        % Randomly select tournamentSize individuals
        contestants = randperm(popSize, tournamentSize);
        [~, bestIdx] = min(fitness(contestants));
        selected(i,:) = pop(contestants(bestIdx),:);
    end
end

% Single-point crossover
function offspring = crossover(parents, pc, popSize, totalBits)
    offspring = parents;
    
    for i = 1:2:popSize-1
        if rand < pc
            % Select crossover point
            cp = randi([1, totalBits-1]);
            
            % Perform crossover
            offspring(i,:) = [parents(i,1:cp), parents(i+1,cp+1:end)];
            offspring(i+1,:) = [parents(i+1,1:cp), parents(i,cp+1:end)];
        end
    end
end

% Bit-flip mutation
function offspring = mutation(offspring, pm)
    mask = rand(size(offspring)) < pm;
    offspring = mod(offspring + mask, 2);
end