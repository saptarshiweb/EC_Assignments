function convergence_comparison()

    % Load data from files
    optimalData = readtable('results_optimal.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    approxData  = readtable('results_approx.txt',  'Delimiter', ',', 'VariableNamingRule', 'preserve');
    gaBinaryData = readtable('results_ga_binary.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    gaRealData = readtable('results_ga_real.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');  % Load the new file

    % Extract Instance IDs and values
    optimalIDs = optimalData.InstanceID;
    optimalValues = optimalData.OptimalCost;

    approxIDs = approxData.InstanceID;
    approxValues = approxData.Profit;

    gaBinaryIDs = gaBinaryData.InstanceID;
    gaBinaryValues = gaBinaryData.Profit;

    gaRealIDs = gaRealData.InstanceID;
    gaRealValues = gaRealData.Profit;  % Get profit from the real GA data

    % Match common IDs among all datasets
    [commonIDs12, idxOptimal, idxApprox] = intersect(optimalIDs, approxIDs, 'stable');
    [commonIDs, idx12, idxGA] = intersect(commonIDs12, gaBinaryIDs, 'stable');
    [commonIDsFinal, idxGAReal] = intersect(commonIDs, gaRealIDs, 'stable');  % Match with gaReal

    % Final matching indices
    matchedOptimal = optimalValues(idxOptimal(idx12));
    matchedApprox = approxValues(idxApprox(idx12));
    matchedGA = gaBinaryValues(idxGA);
    matchedGAReal = gaRealValues(idxGAReal);  % Matched real GA results

    % Plot comparison
    figure;
    plot(1:length(commonIDsFinal), matchedOptimal, '-o', 'LineWidth', 2);
    hold on;
    plot(1:length(commonIDsFinal), matchedApprox, '-x', 'LineWidth', 2);
    plot(1:length(commonIDsFinal), matchedGA, '-s', 'LineWidth', 2);
    plot(1:length(commonIDsFinal), matchedGAReal, '-^', 'LineWidth', 2);  % Add real GA to the plot

    xlabel('Instance Index');
    ylabel('Profit');
    title('Optimal vs Approximate vs GA Binary vs GA Real Profit Comparison');
    legend('Optimal', 'Approximate', 'GA (Binary)', 'GA (Real)','Location','northwest');
    grid on;

end
