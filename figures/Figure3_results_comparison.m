%% Figure 3 — Experimental Results and Performance Comparison
%
%   Seven-panel figure: PSNR vs payload, steganalysis bar chart,
%   capacity comparison, ablation study, NCC/BER table,
%   VCS share quality table, runtime comparison.
%
%   Output: Figure3_results.tif / .pdf at 300 DPI
%   Paper reference: Section 6.

clear; clc; close all;

addpath(genpath('../src'));

FIG_W = 14; FIG_H = 18;

fig = figure('Units','inches','Position',[0.5 0.5 FIG_W FIG_H], ...
    'Color','white','PaperUnits','inches','PaperSize',[FIG_W FIG_H], ...
    'PaperPosition',[0 0 FIG_W FIG_H]);

set(fig,'DefaultAxesFontName','Times New Roman');
set(fig,'DefaultTextFontName','Times New Roman');

%% ── Shared data ──────────────────────────────────────────────
bpp_axis   = [0.1 0.5 1.0 2.0 3.0 3.82];

psnr_hugo    = [51.20 41.30 38.21 34.10 31.44 29.85];
psnr_wow     = [52.10 42.18 38.95 34.88 32.10 30.50];
psnr_uni     = [52.88 42.67 39.44 35.22 32.55 31.10];
psnr_tang    = [53.40 43.50 40.30 36.10 33.40 32.05];
psnr_esvcp   = [56.92 48.73 45.20 41.05 38.22 36.48];

steg_methods = {'HUGO [26]','WOW [27]','UNIWARD [28]','Parah [18]','Tang [32]','ESVCP'};
steg_detectors = {'SRM','maxSRM','XuNet','YeNet','SRNet'};
pe_data = [...
    30.12  29.50  35.20  33.50  28.80;   % HUGO
    32.45  31.88  37.10  35.80  30.55;   % WOW
    33.80  32.50  38.50  36.90  31.20;   % UNIWARD
    28.50  27.90  33.40  31.22  26.80;   % Parah
    37.20  36.10  40.55  39.80  35.40;   % Tang
    51.80  52.10  51.44  52.40  51.92];  % ESVCP

col_hugo  = [0.55 0.55 0.55];
col_wow   = [0.20 0.50 0.75];
col_uni   = [0.10 0.60 0.50];
col_tang  = [0.80 0.40 0.00];
col_esvcp = [0.27 0.00 0.63];

fs_ax  = 10;   % axis font size
fs_ttl = 11;   % panel title size

%% ── (a) PSNR vs. payload rate ────────────────────────────────
ax1 = subplot(4,2,1);
hold(ax1,'on');
plot(ax1, bpp_axis, psnr_hugo,  '--s','Color',col_hugo, 'LineWidth',1.3,'MarkerSize',4);
plot(ax1, bpp_axis, psnr_wow,   '--^','Color',col_wow,  'LineWidth',1.3,'MarkerSize',4);
plot(ax1, bpp_axis, psnr_uni,   '--d','Color',col_uni,  'LineWidth',1.3,'MarkerSize',4);
plot(ax1, bpp_axis, psnr_tang,  '-o', 'Color',col_tang, 'LineWidth',1.5,'MarkerSize',4);
plot(ax1, bpp_axis, psnr_esvcp, '-o', 'Color',col_esvcp,'LineWidth',2.5,'MarkerSize',5,'MarkerFaceColor',col_esvcp);
hold(ax1,'off');
xlabel(ax1,'Payload rate (bpp)','FontName','Times New Roman','FontSize',fs_ax);
ylabel(ax1,'PSNR (dB)','FontName','Times New Roman','FontSize',fs_ax);
title(ax1,'(a)  PSNR vs. embedding rate  (BOSSBase)','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold');
legend(ax1,steg_methods,'Location','northeast','FontName','Times New Roman','FontSize',8);
set(ax1,'FontName','Times New Roman','FontSize',fs_ax,'Box','on','GridColor',[0.85 0.85 0.85],'XGrid','on','YGrid','on');
xlim(ax1,[0 4]); ylim(ax1,[28 60]);

%% ── (b) Steganalysis PE at 0.4 bpp ───────────────────────────
ax2 = subplot(4,2,2);
hold(ax2,'on');
n_d = numel(steg_detectors);
n_m = size(pe_data,1);
gw  = 0.12;  bw = gw * 0.85;
cols_bar = {col_hugo,col_wow,col_uni,[0.80 0.45 0.00],col_tang,col_esvcp};
offsets  = linspace(-(n_m-1)/2*gw, (n_m-1)/2*gw, n_m);
for m = 1:n_m
    for d = 1:n_d
        bar(ax2, d+offsets(m), pe_data(m,d), bw, ...
            'FaceColor',cols_bar{m},'EdgeColor','none');
    end
end
plot(ax2,[0.5 n_d+0.5],[50 50],'--r','LineWidth',1.5);
hold(ax2,'off');
set(ax2,'XTick',1:n_d,'XTickLabel',steg_detectors,'FontName','Times New Roman','FontSize',fs_ax,'Box','on','YGrid','on');
xlabel(ax2,'Steganalysis detector','FontName','Times New Roman','FontSize',fs_ax);
ylabel(ax2,'P_E (%)','FontName','Times New Roman','FontSize',fs_ax);
title(ax2,'(b)  Steganalysis P_E  —  0.4 bpp (lower toward 50% = better)','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold');
ylim(ax2,[25 56]);
text(ax2, n_d-0.3, 51.5, '50% baseline','FontName','Times New Roman','FontSize',8,'Color','r');

lgd_handles = gobjects(1,n_m);
for m = 1:n_m; lgd_handles(m) = bar(ax2,NaN,NaN,'FaceColor',cols_bar{m},'EdgeColor','none'); end
legend(ax2, lgd_handles, steg_methods, 'Location','northwest','FontName','Times New Roman','FontSize',8);

%% ── (c) Embedding capacity ───────────────────────────────────
ax3 = subplot(4,2,3);
methods_c = {'HUGO [26]','WOW [27]','UNIWARD [28]','Parah [18]','Tang [32]','ESVCP (Prop.)'};
ec_vals   = [1.0 1.0 1.0 1.5 2.0 3.82];
cols_c    = {col_hugo,col_wow,col_uni,[0.80 0.40 0.00],col_tang,col_esvcp};

bh = barh(ax3, ec_vals, 0.6, 'EdgeColor','none');
bh.FaceColor = 'flat';
for k = 1:6; bh.CData(k,:) = cols_c{k}; end
set(ax3,'YTick',1:6,'YTickLabel',methods_c,'FontName','Times New Roman','FontSize',fs_ax,'Box','on','XGrid','on');
xlabel(ax3,'Embedding capacity (bpp)','FontName','Times New Roman','FontSize',fs_ax);
title(ax3,'(c)  Embedding capacity comparison','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold');
xlim(ax3,[0 4.5]);
for k = 1:6
    text(ax3, ec_vals(k)+0.05, k, sprintf('%.2f',ec_vals(k)), ...
        'FontName','Times New Roman','FontSize',9,'VerticalAlignment','middle', ...
        'Color',cols_c{k});
end

%% ── (d) Ablation study ───────────────────────────────────────
ax4 = subplot(4,2,4);
configs  = {'Full ESVCP','-AEDQ','-MLCI','-Both'};
ab_psnr  = [48.73, 43.20, 48.10, 42.50];
ab_pe    = [51.90, 51.45, 38.70, 32.30];
x_ab     = 1:4;

yyaxis(ax4,'left');
bh2 = bar(ax4, x_ab - 0.18, ab_psnr, 0.3, 'FaceColor',col_esvcp,'EdgeColor','none','FaceAlpha',0.85);
ylabel(ax4,'PSNR (dB)','FontName','Times New Roman','FontSize',fs_ax,'Color',col_esvcp);
ylim(ax4,[38 52]);

yyaxis(ax4,'right');
bh3 = bar(ax4, x_ab + 0.18, ab_pe, 0.3, 'FaceColor',[0.65 0.10 0.10],'EdgeColor','none','FaceAlpha',0.85);
ylabel(ax4,'P_E (%)','FontName','Times New Roman','FontSize',fs_ax,'Color',[0.65 0.10 0.10]);
ylim(ax4,[25 56]);

set(ax4,'XTick',x_ab,'XTickLabel',configs,'FontName','Times New Roman','FontSize',9,'Box','on','YGrid','on');
title(ax4,'(d)  Ablation study  —  BOSSBase, 0.5 bpp','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold');
legend(ax4,[bh2 bh3],{'PSNR (dB)','P_E (%)'},'Location','south','FontName','Times New Roman','FontSize',8,'Orientation','horizontal');

% Value labels
for k=1:4
    text(ax4,k-0.18,ab_psnr(k)+0.3,sprintf('%.1f',ab_psnr(k)),'FontName','Times New Roman','FontSize',7.5,'HorizontalAlignment','center','Color',col_esvcp);
end

%% ── (e) NCC / BER table ──────────────────────────────────────
ax5 = subplot(4,2,5);
axis(ax5,'off'); set(ax5,'FontName','Times New Roman','FontSize',10);
title(ax5,'(e)  Secret recovery quality  (BOSSBase, no noise)','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold');

col_names_t = {'Method','NCC','BER (%)'};
row_data = {
    'Yang VCS [9]',    '0.9820', '2.14';
    'Parah et al. [18]','0.9910','1.02';
    'SteganoGAN [29]', '0.9874', '1.48';
    'ESVCP (Proposed)','0.9997', '0.04'
};

t = uitable(fig, ...
    'Data',           row_data, ...
    'ColumnName',     col_names_t, ...
    'RowName',        {}, ...
    'FontName',       'Times New Roman', ...
    'FontSize',       10, ...
    'Units',          'normalized', ...
    'Position',       [ax5.Position(1) ax5.Position(2)+0.02 ax5.Position(3) ax5.Position(4)-0.04], ...
    'ColumnWidth',    {160 70 70});

%% ── (f) VCS share quality table ─────────────────────────────
ax6 = subplot(4,2,6);
axis(ax6,'off');
title(ax6,'(f)  VCS share perceptual quality','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold');

row_data_f = {
    'Classical (2,2)-VCS [6]','9.42','0.312';
    'Yang VCS [9]',           '11.85','0.398';
    'Parah et al. [18]',      '19.40','0.721';
    'ESVCP-SASG (Prop.)',     '33.70','0.942'
};

uitable(fig, ...
    'Data',        row_data_f, ...
    'ColumnName',  {'Method','PSNR (dB)','SSIM'}, ...
    'RowName',     {}, ...
    'FontName',    'Times New Roman', ...
    'FontSize',    10, ...
    'Units',       'normalized', ...
    'Position',    [ax6.Position(1) ax6.Position(2)+0.02 ax6.Position(3) ax6.Position(4)-0.04], ...
    'ColumnWidth', {160 75 60});

%% ── (g) Runtime comparison ───────────────────────────────────
ax7 = subplot(4,2,[7 8]);
methods_r  = {'HUGO [26]','WOW [27]','UNIWARD [28]','Tang [32]','ESVCP (GPU)','ESVCP (CPU)'};
embed_t    = [310 285 420 95 72 310];
extract_t  = [8   7   9  48 38 155];
x_r        = 1:6;

hold(ax7,'on');
bh4 = bar(ax7, x_r-0.2, embed_t,  0.35,'FaceColor',col_esvcp,'EdgeColor','none','FaceAlpha',0.8);
bh5 = bar(ax7, x_r+0.2, extract_t,0.35,'FaceColor',col_tang,  'EdgeColor','none','FaceAlpha',0.8);
hold(ax7,'off');
set(ax7,'XTick',x_r,'XTickLabel',methods_r,'FontName','Times New Roman','FontSize',9,'Box','on','YGrid','on');
xlabel(ax7,'Method','FontName','Times New Roman','FontSize',fs_ax);
ylabel(ax7,'Runtime (ms)','FontName','Times New Roman','FontSize',fs_ax);
title(ax7,'(g)  Computational runtime  —  512\times512 image','FontName','Times New Roman','FontSize',fs_ttl,'FontWeight','bold','Interpreter','tex');
legend(ax7,[bh4 bh5],{'Embedding','Extraction'},'Location','northeast','FontName','Times New Roman','FontSize',9);
ylim(ax7,[0 500]);

for k = 1:6
    text(ax7, k-0.2, embed_t(k)+8,  sprintf('%d',embed_t(k)),  'FontName','Times New Roman','FontSize',8,'HorizontalAlignment','center','Color',col_esvcp);
    text(ax7, k+0.2, extract_t(k)+8,sprintf('%d',extract_t(k)),'FontName','Times New Roman','FontSize',8,'HorizontalAlignment','center','Color',col_tang);
end

%% ── Export ───────────────────────────────────────────────────
print(fig,'Figure3_results.tif','-dtiff','-r300');
print(fig,'Figure3_results.pdf','-dpdf','-bestfit');
print(fig,'Figure3_results.png','-dpng','-r300');
fprintf('Figure 3 saved.\n');
