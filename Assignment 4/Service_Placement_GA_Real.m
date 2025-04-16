function solve_large_gap_ga()
    results = {};  % Cell array to store results

    % Iterate through gap1 to gap12 dataset files
    for g = 1:12
        filename = sprintf('gap%d.txt', g);
        fid = fopen(filename, 'r');
        if fid == -1
            error('Error opening file %s.', filename);
        end

        % Read the number of problem sets
        num_problems = fscanf(fid, '%d', 1);

        % Print dataset name (gapX)
        fprintf('\n%s\n', filename(1:end-4)); % Removes .txt for display

        for p = 1:num_problems
            m = fscanf(fid, '%d', 1); % Number of servers
            n = fscanf(fid, '%d', 1); % Number of users
            c = fscanf(fid, '%d', [n, m])';
            r = fscanf(fid, '%d', [n, m])';
            b = fscanf(fid, '%d', [m, 1]);

            is_gap12 = (g == 12);  % For convergence plot

            [x_matrix, fitness_log] = solve_gap_ga(m, n, c, r, b, is_gap12);
            objective_value = sum(sum(c .* x_matrix)); % Maximization

            instance_id = sprintf('c%d-%d', m*100 + n, p);
            fprintf('%s  %d\n', instance_id, round(objective_value));
            results{end+1, 1} = instance_id;
            results{end, 2} = round(objective_value);

            % Plot convergence for GAP12
            if is_gap12
                figure;
                plot(1:length(fitness_log), fitness_log, '-o', 'LineWidth', 2);
                xlabel('Generation');
                ylabel('Best Fitness Value');
                title(sprintf('Fitness Convergence for %s - Problem %d', filename(1:end-4), p));
                grid on;
            end
        end
        fclose(fid);
    end

    % Save to file
    output_filename = fullfile(pwd, 'results_ga_real.txt');
    outFile = fopen(output_filename, 'w');
    if outFile == -1
        error('Unable to open the output file: %s', output_filename);
    end

    fprintf(outFile, 'InstanceID,Profit\n');
    for i = 1:size(results, 1)
        instance_id = results{i, 1};
        profit = results{i, 2};
        fprintf(outFile, '%s,%d\n', instance_id, profit);
    end

    fclose(outFile);
    fprintf('Results successfully saved to %s\n', output_filename);
end

function [x_matrix, fitness_log] = solve_gap_ga(m, n, c, r, b, plot_convergence)
    pop_size = 100;
    max_gen = 100;
    crossover_rate = 0.8;
    mutation_rate = 0.02;
    eta = 20;  % Distribution index for SBX

    fitness_log = zeros(1, max_gen);

    population = rand(pop_size, m * n);
    for i = 1:pop_size
        population(i, :) = enforce_feasibility(rand(1, m * n), m, n);
    end

    fitness = arrayfun(@(i) fitnessFcn(population(i, :)), 1:pop_size);

    for gen = 1:max_gen
        parents = tournamentSelection(population, fitness);
        offspring = simulatedBinaryCrossover(parents, crossover_rate, eta);
        mutated_offspring = mutation(offspring, mutation_rate);

        for i = 1:size(mutated_offspring, 1)
            mutated_offspring(i, :) = enforce_feasibility(mutated_offspring(i, :), m, n);
        end

        new_fitness = arrayfun(@(i) fitnessFcn(mutated_offspring(i, :)), 1:size(mutated_offspring, 1));

        [~, best_idx] = max([fitness, new_fitness]);
        if best_idx > length(fitness)
            population = mutated_offspring;
            fitness = new_fitness;
        else
            population = [population; mutated_offspring];
            fitness = [fitness, new_fitness];
        end

        [~, sorted_idx] = sort(fitness, 'descend');
        population = population(sorted_idx(1:pop_size), :);
        fitness = fitness(sorted_idx(1:pop_size));

        if plot_convergence
            fitness_log(gen) = fitness(1);  % Store best fitness of current gen
        end
    end

    [~, best_idx] = max(fitness);
    x_matrix = reshape(population(best_idx, :), [m, n]);

    function fval = fitnessFcn(x)
        x_mat = reshape(x, [m, n]);
        cost = sum(sum(c .* x_mat));
        capacity_violation = sum(max(sum(x_mat .* r, 2) - b, 0));
        assignment_violation = sum(abs(sum(x_mat, 1) - 1));
        penalty = 1e6 * (capacity_violation + assignment_violation);
        fval = cost - penalty;
    end
end

function selected = tournamentSelection(population, fitness)
    pop_size = size(population, 1);
    selected = zeros(size(population));
    for i = 1:pop_size
        idx1 = randi(pop_size);
        idx2 = randi(pop_size);
        if fitness(idx1) > fitness(idx2)
            selected(i, :) = population(idx1, :);
        else
            selected(i, :) = population(idx2, :);
        end
    end
end

function offspring = simulatedBinaryCrossover(parents, crossover_rate, eta)
    pop_size = size(parents, 1);
    num_genes = size(parents, 2);
    offspring = parents;
    
    for i = 1:2:pop_size-1
        if rand < crossover_rate
            % Select parents
            parent1 = parents(i, :);
            parent2 = parents(i+1, :);

            % Generate offspring using SBX
            for j = 1:num_genes
                u = rand;
                if u <= 0.5
                    beta = (2 * u)^(1 / (eta + 1));
                else
                    beta = (1 / (2 * (1 - u)))^(1 / (eta + 1));
                end

                offspring(i, j) = 0.5 * ((1 + beta) * parent1(j) + (1 - beta) * parent2(j));
                offspring(i+1, j) = 0.5 * ((1 - beta) * parent1(j) + (1 + beta) * parent2(j));
            end
        end
    end
end

function mutated = mutation(offspring, mutation_rate)
    mutated = offspring;
    for i = 1:numel(offspring)
        if rand < mutation_rate
            mutated(i) = rand;  % Real-valued mutation
        end
    end
end

function x_corrected = enforce_feasibility(x, m, n)
    x_mat = reshape(x, [m, n]);
    for j = 1:n
        [~, idx] = max(x_mat(:, j));
        x_mat(:, j) = 0;
        x_mat(idx, j) = 1;
    end
    x_corrected = reshape(x_mat, [1, m * n]);
end
