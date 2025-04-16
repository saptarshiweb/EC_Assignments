function convergence_comparison()

    % Load data from files
    optimalData = readtable('results_optimal.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    approxData  = readtable('results_approx.txt',  'Delimiter', ',', 'VariableNamingRule', 'preserve');

    % Extract Instance IDs and values
    optimalIDs = optimalData.InstanceID;
    optimalValues = optimalData.OptimalCost;

    approxIDs = approxData.InstanceID;
    approxValues = approxData.Profit;

    % Match IDs between optimal and approx
    [commonIDs, idxOptimal, idxApprox] = intersect(optimalIDs, approxIDs, 'stable');

    % Extract corresponding profits
    matchedOptimal = optimalValues(idxOptimal);
    matchedApprox = approxValues(idxApprox);

    % Plot only the comparison of Optimal vs Approximate
    figure;
    plot(1:length(commonIDs), matchedOptimal, '-o', 'LineWidth', 2);
    hold on;
    plot(1:length(commonIDs), matchedApprox, '-x', 'LineWidth', 2);
    xlabel('Instance Index');
    ylabel('Profit');
    title('Optimal vs Approximate Profit Comparison');
    legend('Optimal', 'Approximate','Location','northwest');
    grid on;

end
