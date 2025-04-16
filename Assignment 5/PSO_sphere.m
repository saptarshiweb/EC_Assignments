function PSO_sphere()
    % Parameters
    nVars = 4;          % Number of variables
    nParticles = 50;    % Number of particles
    maxIter = 100;      % Maximum iterations
    w = 0.729;          % Inertia weight
    c1 = 1.49445;       % Cognitive coefficient
    c2 = 1.49445;       % Social coefficient
    
    % Variable bounds
    lowerBound = -10 * ones(1, nVars);
    upperBound = 10 * ones(1, nVars);
    
    % Initialize particles
    particles = repmat(lowerBound, nParticles, 1) + ...
                repmat(upperBound - lowerBound, nParticles, 1) .* rand(nParticles, nVars);
    
    % Initialize velocities
    velocities = zeros(nParticles, nVars);
    
    % Initialize personal best
    personalBest = particles;
    personalBestFitness = inf(nParticles, 1);
    
    % Initialize global best
    globalBest = zeros(1, nVars);
    globalBestFitness = inf;
    
    % Fitness history
    fitnessHistory = zeros(maxIter, 1);
    
    % Evaluate initial population
    for i = 1:nParticles
        currentFitness = sphereFunction(particles(i,:));
        personalBestFitness(i) = currentFitness;
        
        if currentFitness < globalBestFitness
            globalBestFitness = currentFitness;
            globalBest = particles(i,:);
        end
    end
    
    % Main PSO loop
    for iter = 1:maxIter
        for i = 1:nParticles
            % Update velocity
            r1 = rand(1, nVars);
            r2 = rand(1, nVars);
            cognitive = c1 * r1 .* (personalBest(i,:) - particles(i,:));
            social = c2 * r2 .* (globalBest - particles(i,:));
            velocities(i,:) = w * velocities(i,:) + cognitive + social;
            
            % Update position
            particles(i,:) = particles(i,:) + velocities(i,:);
            
            % Apply bounds
            particles(i,:) = max(particles(i,:), lowerBound);
            particles(i,:) = min(particles(i,:), upperBound);
            
            % Evaluate fitness
            currentFitness = sphereFunction(particles(i,:));
            
            % Update personal best
            if currentFitness < personalBestFitness(i)
                personalBestFitness(i) = currentFitness;
                personalBest(i,:) = particles(i,:);
                
                % Update global best
                if currentFitness < globalBestFitness
                    globalBestFitness = currentFitness;
                    globalBest = particles(i,:);
                end
            end
        end
        
        % Store best fitness
        fitnessHistory(iter) = globalBestFitness;
        
        % Display progress
        if mod(iter, 10) == 0
            fprintf('Iteration %d: Best fitness = %f\n', iter, globalBestFitness);
        end
    end
    
    % Results
    fprintf('\nOptimization completed:\n');
    fprintf('Best solution found: [%f, %f, %f, %f]\n', globalBest);
    fprintf('Minimum function value: %f\n', globalBestFitness);
    
    % Plot fitness history
    figure;
    plot(1:maxIter, fitnessHistory, 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Best Fitness');
    title('Convergence of PSO on Sphere Function');
    grid on;
end

% Sphere function
function f = sphereFunction(x)
    f = sum(x.^2);
end