function convergence_comparison()

    % Load data from files
    optimalData = readtable('results_optimal.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    approxData  = readtable('results_approx.txt',  'Delimiter', ',', 'VariableNamingRule', 'preserve');
    gaBinaryData = readtable('results_ga_binary.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    gaRealData = readtable('results_ga_real.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    psoData = readtable('results_pso.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
    tlboData = readtable('results_tlbo.txt', 'Delimiter', ',', 'VariableNamingRule', 'preserve');  % New line

    % Extract Instance IDs and values
    optimalIDs = optimalData.InstanceID;
    optimalValues = optimalData.OptimalCost;

    approxIDs = approxData.InstanceID;
    approxValues = approxData.Profit;

    gaBinaryIDs = gaBinaryData.InstanceID;
    gaBinaryValues = gaBinaryData.Profit;

    gaRealIDs = gaRealData.InstanceID;
    gaRealValues = gaRealData.Profit;

    psoIDs = psoData.InstanceID;
    psoValues = psoData.Profit;

    tlboIDs = tlboData.InstanceID;
    tlboValues = tlboData.Profit;  % New line

    % Match common IDs among all datasets step-by-step
    [commonIDs12, idxOptimal, idxApprox] = intersect(optimalIDs, approxIDs, 'stable');
    [commonIDs, idx12, idxGA] = intersect(commonIDs12, gaBinaryIDs, 'stable');
    [commonIDsFinal, idxGAReal] = intersect(commonIDs, gaRealIDs, 'stable');
    [commonIDsFinal2, idxPSO] = intersect(commonIDsFinal, psoIDs, 'stable');
    [commonIDsFinal3, idxTLBO] = intersect(commonIDsFinal2, tlboIDs, 'stable');  % Match with TLBO

    % Final matched values
    matchedOptimal = optimalValues(idxOptimal(idx12(idxGAReal(idxPSO))));
    matchedApprox = approxValues(idxApprox(idx12(idxGAReal(idxPSO))));
    matchedGA = gaBinaryValues(idxGA(idxGAReal(idxPSO)));
    matchedGAReal = gaRealValues(idxGAReal(idxPSO));
    matchedPSO = psoValues(idxPSO);
    matchedTLBO = tlboValues(idxTLBO);  % New line

    % Plot comparison
    figure;
    plot(1:length(commonIDsFinal3), matchedOptimal, '-o', 'LineWidth', 2);
    hold on;
    plot(1:length(commonIDsFinal3), matchedApprox, '-x', 'LineWidth', 2);
    plot(1:length(commonIDsFinal3), matchedGA, '-s', 'LineWidth', 2);
    plot(1:length(commonIDsFinal3), matchedGAReal, '-^', 'LineWidth', 2);
    plot(1:length(commonIDsFinal3), matchedPSO, '-d', 'LineWidth', 2);
    plot(1:length(commonIDsFinal3), matchedTLBO, '-p', 'LineWidth', 2);  % New line

    xlabel('Instance Index');
    ylabel('Profit');
    title('Optimal vs Approximate vs GA (Binary) vs GA (Real) vs PSO vs TLBO');
    legend('Optimal', 'Approximate', 'GA (Binary)', 'GA (Real)', 'PSO', 'TLBO','Location','northwest');
    grid on;

end
