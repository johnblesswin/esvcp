%% Figure 2 — Detailed Innovation Module Flowcharts
%
%   Three-panel figure showing AEDQ, MLCI, and SASG internals.
%   Output: Figure2_innovations.tif / .pdf at 300 DPI
%   Paper reference: Section 4.

clear; clc; close all;

FIG_W = 14; FIG_H = 10;

fig = figure('Units','inches','Position',[0.5 0.5 FIG_W FIG_H], ...
    'Color','white','PaperUnits','inches','PaperSize',[FIG_W FIG_H], ...
    'PaperPosition',[0 0 FIG_W FIG_H]);

set(fig,'DefaultAxesFontName','Times New Roman');
set(fig,'DefaultTextFontName','Times New Roman');

sgtitle('Figure 2.  Detailed operation of the three ESVCP innovation modules', ...
    'FontName','Times New Roman','FontSize',14,'FontWeight','bold');

% ══ Panel 1: AEDQ ══════════════════════════════════════════
ax1 = subplot(1,3,1);
axis(ax1, [0 10 0 24]); axis(ax1, 'off');
title(ax1, 'Innovation I: AEDQ Module', ...
    'FontName','Times New Roman','FontSize',12,'FontWeight','bold', ...
    'Color',[0.27 0 0.63]);

steps = {
    'Input: Cover $I_c$';
    'Local entropy $H(i,j) = -\Sigma p \log p$';
    'Normalise $\tilde{H} = H/H_{max}$';
    'Sigmoid $\alpha = 1/(1+e^{-\beta(\tilde{H}-\theta)})$';
    'Kernel $W = \alpha W_{FS} + (1-\alpha) W_{JJN}$';
    'Error diffusion embedding';
    'Output: Modified $I_s$ (low distortion)'
};
colors = {[0.95 0.91 1.00]};

y = 22;
for i = 1:numel(steps)
    rectangle('Position',[1 y-1.8 8 1.6],'Curvature',[0.1 0.1], ...
        'FaceColor',colors{1},'EdgeColor',[0.27 0 0.63],'LineWidth',0.8,'Parent',ax1);
    text(5, y-1, steps{i}, 'Parent',ax1, ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName','Times New Roman','FontSize',9,'FontWeight','bold', ...
        'Color',[0.15 0 0.5],'Interpreter','latex');
    if i < numel(steps)
        annotation_arrow_local(ax1, 5, y-1.9, 5, y-2.4);
    end
    y = y - 2.9;
end

% ══ Panel 2: MLCI ══════════════════════════════════════════
ax2 = subplot(1,3,2);
axis(ax2, [0 10 0 24]); axis(ax2, 'off');
title(ax2, 'Innovation II: MLCI Module', ...
    'FontName','Times New Roman','FontSize',12,'FontWeight','bold', ...
    'Color',[0.08 0.3 0.65]);

steps2 = {
    'Input: $I_c$, secret $\mathcal{S}$, key $k_1$';
    'Bit-plane decomp. $I_c = \Sigma B_k 2^k$';
    'Asymmetric load B$_0$=60\%, B$_1$=30\%, B$_2$=10\%';
    'Logistic map $x_{n+1}=\mu x_n (1-x_n)$';
    'Permutation $\pi = \mathrm{argsort}\{x_i\}$';
    'Bit embedding $B_k^\prime(\mathrm{pos}) = s_l$';
    'Output: Permuted $I_s$, $\chi^2 \to 127$'
};

y = 22;
for i = 1:numel(steps2)
    rectangle('Position',[1 y-1.8 8 1.6],'Curvature',[0.1 0.1], ...
        'FaceColor',[0.91 0.95 1.00],'EdgeColor',[0.08 0.3 0.65],'LineWidth',0.8,'Parent',ax2);
    text(5, y-1, steps2{i}, 'Parent',ax2, ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName','Times New Roman','FontSize',9,'FontWeight','bold', ...
        'Color',[0.04 0.15 0.4],'Interpreter','latex');
    if i < numel(steps2)
        annotation_arrow_local(ax2, 5, y-1.9, 5, y-2.4);
    end
    y = y - 2.9;
end

% ══ Panel 3: SASG ══════════════════════════════════════════
ax3 = subplot(1,3,3);
axis(ax3, [0 10 0 24]); axis(ax3, 'off');
title(ax3, 'Innovation III: SASG Module', ...
    'FontName','Times New Roman','FontSize',12,'FontWeight','bold', ...
    'Color',[0.18 0.49 0.20]);

steps3 = {
    'Input: Cover $I_c$, secret image';
    'U$^2$-Net saliency Sal = $F_{sal}(I_c)$';
    'Binary mask $M_{sal}(i,j)=1$ if Sal$\geq 0.5$';
    'Region partition $\Omega_{sal}$, $\Omega_{free}$';
    'Constrained shares: $V_1 \oplus V_2 = \mathcal{S}$';
    'Contrast $\alpha_r = \frac{|\Omega_{free}|}{MN}\alpha_{VCS}$';
    'Output: Meaningful shares (PSNR 33.7 dB)'
};

y = 22;
for i = 1:numel(steps3)
    rectangle('Position',[1 y-1.8 8 1.6],'Curvature',[0.1 0.1], ...
        'FaceColor',[0.92 0.98 0.92],'EdgeColor',[0.18 0.49 0.20],'LineWidth',0.8,'Parent',ax3);
    text(5, y-1, steps3{i}, 'Parent',ax3, ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName','Times New Roman','FontSize',9,'FontWeight','bold', ...
        'Color',[0.08 0.25 0.1],'Interpreter','latex');
    if i < numel(steps3)
        annotation_arrow_local(ax3, 5, y-1.9, 5, y-2.4);
    end
    y = y - 2.9;
end

% ── Export ───────────────────────────────────────────────────
print(fig, 'Figure2_innovations.tif', '-dtiff', '-r300');
print(fig, 'Figure2_innovations.pdf', '-dpdf', '-bestfit');
print(fig, 'Figure2_innovations.png', '-dpng', '-r300');
fprintf('Figure 2 saved: Figure2_innovations.{tif,pdf,png}\n');

% ── Helper: arrow ────────────────────────────────────────────
function annotation_arrow_local(ax, x1, y1, x2, y2)
    line([x1 x2], [y1 y2], 'Parent', ax, 'Color', 'k', 'LineWidth', 0.9);
    line([x2-0.25 x2], [y2+0.25 y2], 'Parent', ax, 'Color','k','LineWidth',0.9);
    line([x2+0.25 x2], [y2+0.25 y2], 'Parent', ax, 'Color','k','LineWidth',0.9);
end
