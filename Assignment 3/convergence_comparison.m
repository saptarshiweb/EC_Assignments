function convergence_comparison()

    % Load data from files
    optimalData = readtable('results_optimal.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    approxData  = readtable('results_approx.txt',  'Delimiter', ',', 'VariableNamingRule', 'preserve');
    gaData      = readtable('results_ga_binary.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');

    % Extract Instance IDs and values
    optimalIDs = optimalData.InstanceID;
    optimalValues = optimalData.OptimalCost;

    approxIDs = approxData.InstanceID;
    approxValues = approxData.Profit;

    gaIDs = gaData.InstanceID;
    gaValues = gaData.Profit;

    % Match common IDs among all three datasets
    [commonIDs12, idxOptimal, idxApprox] = intersect(optimalIDs, approxIDs, 'stable');
    [commonIDs, idx12, idxGA] = intersect(commonIDs12, gaIDs, 'stable');

    % Final matching indices
    matchedOptimal = optimalValues(idxOptimal(idx12));
    matchedApprox = approxValues(idxApprox(idx12));
    matchedGA = gaValues(idxGA);

    % Plot comparison
    figure;
    plot(1:length(commonIDs), matchedOptimal, '-o', 'LineWidth', 2);
    hold on;
    plot(1:length(commonIDs), matchedApprox, '-x', 'LineWidth', 2);
    plot(1:length(commonIDs), matchedGA, '-s', 'LineWidth', 2);
    
    xlabel('Instance Index');
    ylabel('Profit');
    title('Optimal vs Approximate vs GA Profit Comparison');
    legend('Optimal', 'Approximate', 'GA (Binary)','Location','northwest');
    grid on;

end
