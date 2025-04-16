function TLBO_sphere_improved()
    % Parameters
    nVars = 4;          % Number of variables
    popSize = 50;       % Population size (class size)
    maxIter = 200;      % Maximum iterations (increased for better exploration)
    tol = 1e-6;         % Tolerance for convergence checking
    
    % Variable bounds
    lowerBound = -10 * ones(1, nVars);
    upperBound = 10 * ones(1, nVars);
    
    % Initialize population with better diversity
    population = repmat(lowerBound, popSize, 1) + ...
                 repmat(upperBound - lowerBound, popSize, 1) .* lhsdesign(popSize, nVars, 'iterations', 1000);
    
    % Evaluate initial population
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        fitness(i) = sphereFunction(population(i,:));
    end
    
    % Initialize best solution tracking
    [bestFitness, bestIdx] = min(fitness);
    bestSolution = population(bestIdx,:);
    fitnessHistory = zeros(maxIter, 1);
    diversityHistory = zeros(maxIter, 1);
    
    % Main TLBO loop
    for iter = 1:maxIter
        % Calculate population diversity
        diversity = mean(std(population));
        diversityHistory(iter) = diversity;
        
        % Teacher Phase (Learning from the teacher)
        [~, teacherIdx] = min(fitness);
        teacher = population(teacherIdx,:);
        
        % Calculate mean of the population
        meanPopulation = mean(population, 1);
        
        % Adaptive teaching factor
        TF = 1 + rand();  % Now varies between 1 and 2
        
        % Update each learner with momentum
        newPopulation = population;
        for i = 1:popSize
            % Difference between teacher and mean with small random component
            difference = (teacher - (TF * meanPopulation)) .* (0.9 + 0.2*rand(1,nVars));
            
            % Generate new solution with learning rate adjustment
            learningRate = 0.5 * (1 + (iter/maxIter));  % Decreases over time
            newSolution = population(i,:) + learningRate * rand(1, nVars) .* difference;
            
            % Apply bounds with bounce-back
            outOfBounds = (newSolution < lowerBound) | (newSolution > upperBound);
            newSolution(outOfBounds) = population(i,outOfBounds) - 0.5*rand(1,sum(outOfBounds)) .* ...
                                      (newSolution(outOfBounds) - population(i,outOfBounds));
            
            % Ensure we stay within bounds
            newSolution = max(newSolution, lowerBound);
            newSolution = min(newSolution, upperBound);
            
            % Evaluate new solution
            newFitness = sphereFunction(newSolution);
            
            % Greedy selection with small probability to accept worse solutions
            if newFitness < fitness(i) || rand() < 0.05*(1-iter/maxIter)
                newPopulation(i,:) = newSolution;
                fitness(i) = newFitness;
            end
        end
        population = newPopulation;
        
        % Learner Phase (Learning from peers with diversity maintenance)
        for i = 1:popSize
            % Select partner using tournament selection for better diversity
            candidates = randperm(popSize, 3);
            [~, bestCandidate] = min(fitness(candidates));
            partner = candidates(bestCandidate);
            if partner == i
                partner = candidates(mod(bestCandidate,3)+1);
            end
            
            % Adaptive learning from partner
            if fitness(i) < fitness(partner)
                difference = (population(i,:) - population(partner,:)) .* (0.5 + rand(1,nVars));
            else
                difference = (population(partner,:) - population(i,:)) .* (0.5 + rand(1,nVars));
            end
            
            % Generate new solution with decreasing perturbation
            perturbation = 0.1 * (maxIter - iter)/maxIter;
            newSolution = population(i,:) + (rand(1,nVars)+perturbation) .* difference;
            
            % Apply bounds with reflection
            newSolution = max(newSolution, lowerBound);
            newSolution = min(newSolution, upperBound);
            
            % Evaluate new solution
            newFitness = sphereFunction(newSolution);
            
            % Probabilistic acceptance
            if newFitness < fitness(i) || rand() < exp((fitness(i)-newFitness)/diversity)
                population(i,:) = newSolution;
                fitness(i) = newFitness;
            end
        end
        
        % Update best solution
        [currentBest, idx] = min(fitness);
        if currentBest < bestFitness
            bestFitness = currentBest;
            bestSolution = population(idx,:);
        end
        fitnessHistory(iter) = bestFitness;
        
        % Display progress with diversity information
        if mod(iter, 10) == 0
            fprintf('Iter %4d: BestFit = %.4e, Diversity = %.4f\n', ...
                    iter, bestFitness, diversity);
        end
        
        % Early stopping if diversity is too low but solution not optimal
        if diversity < tol && bestFitness > tol
            fprintf('Restarting due to premature convergence\n');
            % Reset worst half of population
            [~, worstIdx] = sort(fitness, 'descend');
            population(worstIdx(1:round(popSize/2)),:) = ...
                repmat(lowerBound, round(popSize/2), 1) + ...
                repmat(upperBound - lowerBound, round(popSize/2), 1) .* rand(round(popSize/2), nVars);
            % Re-evaluate
            for i = worstIdx(1:round(popSize/2))
                fitness(i) = sphereFunction(population(i,:));
            end
        end
        
        % Check for true convergence
        if bestFitness < tol
            break;
        end
    end
    
    % Results
    fprintf('\nOptimization completed after %d iterations:\n', iter);
    fprintf('Best solution found: [');
    fprintf('%.6f, ', bestSolution(1:end-1));
    fprintf('%.6f]\n', bestSolution(end));
    fprintf('Minimum function value: %.12f\n', bestFitness);
    fprintf('Final diversity measure: %f\n', diversity);
    
    % Plot results
    figure;
    subplot(2,1,1);
    plot(1:iter, fitnessHistory(1:iter), 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Best Fitness');
    title('Convergence of Improved TLBO on Sphere Function');
    grid on;
    
    subplot(2,1,2);
    plot(1:iter, diversityHistory(1:iter), 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Population Diversity');
    title('Population Diversity During Optimization');
    grid on;
end

% Sphere function with numerical stability check
function f = sphereFunction(x)
    % Add small noise to prevent exact zero comparisons
    perturbed_x = x + 1e-10*randn(size(x));
    f = sum(perturbed_x.^2);
end