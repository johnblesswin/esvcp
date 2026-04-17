%% Figure 1 — ESVCP System Architecture Block Diagram
%
%   Generates the high-level block diagram showing embedding pipeline,
%   extraction pipeline, and security evaluation panel.
%
%   Output: Figure1_architecture.tif / .pdf / .png at 300 DPI
%   Paper reference: Section 3.4.

clear; clc; close all;

FIG_W = 10; FIG_H = 14;

fig = figure('Units','inches','Position',[0.5 0.5 FIG_W FIG_H], ...
    'Color','white','PaperUnits','inches','PaperSize',[FIG_W FIG_H], ...
    'PaperPosition',[0 0 FIG_W FIG_H]);

set(fig,'DefaultAxesFontName','Times New Roman');
set(fig,'DefaultTextFontName','Times New Roman');

ax = axes('Position',[0 0 1 1]);
axis(ax, [0 100 0 140]); axis(ax, 'off');

% ── Colour palette ───────────────────────────────────────────
col_purple = [0.27 0.00 0.63];
col_blue   = [0.08 0.40 0.65];
col_gray   = [0.50 0.50 0.50];
col_green  = [0.18 0.49 0.20];
col_amber  = [0.75 0.45 0.00];
col_red    = [0.60 0.10 0.10];

% ── Draw box helper ──────────────────────────────────────────
draw_box = @(x, y, w, h, bg, ec, lw) ...
    rectangle('Position', [x y w h], 'Curvature', [0.08 0.08], ...
              'FaceColor', bg, 'EdgeColor', ec, 'LineWidth', lw);

put_text = @(x, y, s, sz, col, wt) ...
    text(x, y, s, 'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
         'FontName','Times New Roman', 'FontSize', sz, ...
         'FontWeight', wt, 'Color', col, 'Interpreter','latex');

% ── Title ────────────────────────────────────────────────────
put_text(50, 135, '\textbf{Figure 1.~ ESVCP System Architecture}', 14, [0 0 0], 'bold');

% ── Embedding pipeline (dashed frame) ────────────────────────
rectangle('Position',[5 40 55 90],'Curvature',[0.02 0.02], ...
          'EdgeColor',[0.5 0.5 0.5],'LineWidth',0.6,'LineStyle','--');
put_text(8, 131, '\textit{Embedding pipeline}', 9, col_gray, 'normal');

% BOX 1: Cover image
draw_box(10, 115, 22, 8, [0.96 0.96 0.96], col_gray, 0.6);
put_text(21, 119, 'Cover $I_c$', 10, [0 0 0], 'bold');
% BOX 2: Secret
draw_box(35, 115, 22, 8, [0.96 0.96 0.96], col_gray, 0.6);
put_text(46, 119, 'Secret $\mathcal{S}$', 10, [0 0 0], 'bold');

% Arrow merge
line([21 21],[115 110],'Color','k','LineWidth',1);
line([46 46],[115 110],'Color','k','LineWidth',1);
line([21 46],[110 110],'Color','k','LineWidth',1);
annotation('arrow',[0.33 0.33],[0.78 0.76],'Color','k','HeadLength',6,'HeadWidth',6);

% BOX 3: Key set
draw_box(20, 103, 25, 7, [0.96 0.96 0.96], col_gray, 0.6);
put_text(32.5, 106.5, 'Key set $\mathcal{K}$', 10, [0 0 0], 'bold');

% BOX 4: SASG
draw_box(10, 90, 45, 9, [0.95 0.91 1.00], col_purple, 1.3);
put_text(32.5, 96, 'SASG — Semantic Share Gen.', 10, col_purple, 'bold');
put_text(32.5, 92, 'Innovation III  $|$  U$^2$-Net saliency', 8, col_purple, 'normal');

% BOX 5: MLCI
draw_box(10, 78, 45, 9, [0.95 0.91 1.00], col_purple, 1.3);
put_text(32.5, 84, 'MLCI — Multi-Layer LSB + Chaos', 10, col_purple, 'bold');
put_text(32.5, 80, 'Innovation II  $|$  $\mu$=3.9999', 8, col_purple, 'normal');

% BOX 6: AEDQ
draw_box(10, 66, 45, 9, [0.95 0.91 1.00], col_purple, 1.3);
put_text(32.5, 72, 'AEDQ — Adaptive Diffusion', 10, col_purple, 'bold');
put_text(32.5, 68, 'Innovation I  $|$  $\alpha(i,j)$ sigmoid', 8, col_purple, 'normal');

% BOX 7: Stego output
draw_box(12, 52, 41, 9, [0.92 0.98 0.92], col_green, 1.4);
put_text(32.5, 58, 'Stego-image $I_s$', 11, col_green, 'bold');
put_text(32.5, 54, 'PSNR=48.73 dB  $|$  EC=3.82 bpp', 8, col_green, 'normal');

% Vertical arrows (embedding pipeline)
for y = [101 88 76 64]
    annotation('arrow', [0.33 0.33], [y/140+0.01 y/140-0.01], ...
        'Color','k','HeadLength',6,'HeadWidth',6);
end

% ── Channel ──────────────────────────────────────────────────
line([32.5 32.5],[52 46],'Color','k','LineStyle',':','LineWidth',1);
put_text(32.5, 43, 'Public channel', 8, col_gray, 'normal');

% ── Extraction pipeline ──────────────────────────────────────
rectangle('Position',[5 5 55 33],'Curvature',[0.02 0.02], ...
          'EdgeColor',[0.5 0.5 0.5],'LineWidth',0.6,'LineStyle','--');
put_text(8, 37, '\textit{Extraction pipeline}', 9, col_gray, 'normal');

draw_box(12, 28, 41, 7, [1.00 0.97 0.90], col_amber, 1.0);
put_text(32.5, 31.5, 'Inverse MLCI decryption', 10, col_amber, 'bold');

draw_box(12, 18, 41, 7, [1.00 0.97 0.90], col_amber, 1.0);
put_text(32.5, 21.5, 'VCS share superposition', 10, col_amber, 'bold');

draw_box(15, 8, 35, 7, [0.96 0.96 0.96], col_gray, 0.8);
put_text(32.5, 11.5, 'Recovered $\hat{\mathcal{S}}$', 10, [0 0 0], 'bold');
put_text(32.5, 9, 'NCC=0.9997  $|$  BER=0.04\%', 7, col_gray, 'normal');

annotation('arrow',[0.33 0.33],[28/140+0.005 27/140],'Color','k','HeadLength',6);
annotation('arrow',[0.33 0.33],[18/140+0.005 17/140],'Color','k','HeadLength',6);

% ── Security evaluation panel ────────────────────────────────
rectangle('Position',[65 30 30 75],'Curvature',[0.02 0.02], ...
          'EdgeColor',col_red,'LineWidth',0.7);
put_text(80, 102, '\textbf{Security evaluation}', 10, col_red, 'bold');

% Steganalysis
draw_box(67, 88, 26, 10, [1 0.93 0.93], col_red, 0.7);
put_text(80, 95, 'Steganalysis detectors', 9, [0 0 0], 'bold');
put_text(80, 91, 'SRM, YeNet, SRNet, DCTR', 7, [0.2 0.2 0.2], 'normal');

% Detection accuracy
draw_box(67, 74, 26, 9, [1 0.93 0.93], col_red, 0.7);
put_text(80, 80, 'Detection $P_E$', 9, [0 0 0], 'bold');
put_text(80, 76.5, '$\leq 52.4\%$ $\approx$ random', 7, col_red, 'normal');

% Quality metrics
draw_box(67, 58, 26, 13, [1 0.93 0.93], col_red, 0.7);
put_text(80, 68, 'Quality metrics', 9, [0 0 0], 'bold');
put_text(80, 65, 'PSNR = 48.73 dB', 7, [0.2 0.2 0.2], 'normal');
put_text(80, 63, 'SSIM = 0.9961', 7, [0.2 0.2 0.2], 'normal');
put_text(80, 60.5, 'EC = 3.82 bpp', 7, [0.2 0.2 0.2], 'normal');

% Datasets
draw_box(67, 40, 26, 14, [1 0.93 0.93], col_red, 0.7);
put_text(80, 50, 'Benchmark datasets', 9, [0 0 0], 'bold');
put_text(80, 47, 'BOWS-2', 7, [0.2 0.2 0.2], 'normal');
put_text(80, 45, 'BOSSBase v1.01', 7, [0.2 0.2 0.2], 'normal');
put_text(80, 43, 'ALASKA\#2', 7, [0.2 0.2 0.2], 'normal');

% Connectors
for y = [85 72 56]
    line([80 80],[y y-3],'Color',col_red,'LineWidth',0.6,'LineStyle','--');
end

% Arrow from stego → security panel
annotation('arrow',[0.53 0.68],[56/140 72/140],'Color',col_red, ...
    'LineStyle','--','LineWidth',0.7,'HeadLength',6,'HeadWidth',6);

% ── Legend ───────────────────────────────────────────────────
draw_box(5, 1, 90, 3, [0.98 0.98 0.98], col_gray, 0.5);
legend_items = {
    {'Innovation module', [0.95 0.91 1.00], col_purple},
    {'Processing stage',  [0.92 0.98 0.92], col_green},
    {'I/O node',          [0.96 0.96 0.96], col_gray},
    {'Security panel',    [1.00 0.93 0.93], col_red}};
lx = 7;
for li = 1:4
    rectangle('Position',[lx 1.8 2.5 1.4],'Curvature',[0.2 0.2], ...
              'FaceColor',legend_items{li}{2},'EdgeColor',legend_items{li}{3}, 'LineWidth',0.5);
    put_text(lx+11, 2.5, legend_items{li}{1}, 8, [0.2 0.2 0.2], 'normal');
    lx = lx + 22;
end

% ── Export ───────────────────────────────────────────────────
print(fig, 'Figure1_architecture.tif', '-dtiff', '-r300');
print(fig, 'Figure1_architecture.pdf', '-dpdf', '-bestfit');
print(fig, 'Figure1_architecture.png', '-dpng', '-r300');
fprintf('Figure 1 saved: Figure1_architecture.{tif,pdf,png}\n');
