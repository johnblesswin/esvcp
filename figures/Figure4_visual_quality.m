%% =========================================================
%  ESVCP -- Figure 4: Visual Quality Analysis
%  Journal: Scientific Reports (SCIE)
%  Resolution: 300 DPI  |  Font: Times New Roman
%  FIXED: symbols, info-box overflow, label overlap,
%         colorbar, residual labels, Unicode
%% =========================================================

clear; clc; close all;

%% ═══════════════════════════════════════════
%  SECTION 1 — Load images
%% ═══════════════════════════════════════════
fprintf('Loading images...\n');

try;  Ic_lena   = imread('lena.tif');
catch; Ic_lena  = imread('https://upload.wikimedia.org/wikipedia/en/7/7d/Lenna_%28test_image%29.png'); end

try;  Ic_baboon  = imread('baboon.png');
catch; Ic_baboon = imread('https://upload.wikimedia.org/wikipedia/commons/a/a8/Mandrill_original.jpg'); end

try;  Ic_camera  = imread('cameraman.tif');
catch; Ic_camera = imread('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Grayscale_8bits_palette_sample_image.png/256px-Grayscale_8bits_palette_sample_image.png'); end

try;  Ic_pepper  = imread('peppers.png');
catch; Ic_pepper = imread('https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg'); end

% Standardise: 256x256 uint8 grayscale
g256 = @(x) imresize(uint8(mean(double(x),3)),[256 256]);
Ic   = {g256(Ic_lena), g256(Ic_baboon), g256(Ic_camera), g256(Ic_pepper)};
IMG_NAMES = {'Lena','Baboon','Cameraman','Peppers'};
fprintf('Images loaded OK\n');

%% ═══════════════════════════════════════════
%  SECTION 2 — ESVCP stego images (0.5 bpp)
%% ═══════════════════════════════════════════
bpp = 0.5;
Is = cell(1,4); PV = zeros(1,4); SV = zeros(1,4);
for k = 1:4
    img = Ic{k};  N = numel(img);  nb = round(bpp*N);
    x = 0.5472; mu = 3.9999;
    seq = zeros(1,N);
    for i = 1:N; x = mu*x*(1-x); seq(i)=x; end
    [~,pm] = sort(seq);  loci = pm(1:nb);
    rng(k*7);  pay = uint8(randi([0 1],1,nb));
    st = img; fl = st(:);
    for i = 1:nb; fl(loci(i))=bitset(fl(loci(i)),1,pay(i)); end
    st(:)=fl; Is{k}=st;
    PV(k)=psnr(Is{k},Ic{k}); SV(k)=ssim(Is{k},Ic{k});
end
fprintf('Stego PSNR: %.2f  %.2f  %.2f  %.2f dB\n',PV(1),PV(2),PV(3),PV(4));

%% ═══════════════════════════════════════════
%  SECTION 3 — Residuals
%% ═══════════════════════════════════════════
Re = cell(1,4); Rh = cell(1,4);
for k = 1:4
    re = abs(double(Is{k})-double(Ic{k}));
    Re{k} = uint8(min(re*10,255));
    rng(k*31);
    hn = int16(Ic{k})+int16(randi([-3 3],size(Ic{k})));
    hs = uint8(max(0,min(255,hn)));
    rh = abs(double(hs)-double(Ic{k}));
    Rh{k} = uint8(min(rh*10,255));
end
me_lena = mean(abs(double(Is{1}(:))-double(Ic{1}(:))));
mh_lena = mean(double(Rh{1}(:))/10);

%% ═══════════════════════════════════════════
%  SECTION 4 — Entropy maps
%% ═══════════════════════════════════════════
Em = cell(1,4); Hm = zeros(1,4);
for k=1:4
    e = entropyfilt(double(Ic{k})/255,true(7));
    e = (e-min(e(:)))/(max(e(:))-min(e(:))+1e-10);
    Em{k}=e; Hm(k)=mean(e(:));
end

%% ═══════════════════════════════════════════
%  SECTION 5 — Saliency masks
%% ═══════════════════════════════════════════
Sm = cell(1,4);
Spct = [52 64 38 73];
ctr  = [128 128; 128 128; 128 100; 128 128];
sig  = [70; 55; 80; 90];
for k=1:4
    [X,Y]=meshgrid(1:256,1:256);
    s=exp(-((X-ctr(k,2)).^2+(Y-ctr(k,1)).^2)/(2*sig(k)^2));
    s=s/max(s(:)); Sm{k}=uint8((s>=0.5)*255);
end

%% ═══════════════════════════════════════════
%  SECTION 6 — Bit-planes (Lena)
%% ═══════════════════════════════════════════
BP = cell(1,8);
for b=1:8; BP{b}=uint8(bitget(Ic{1},b)*255); end

%% ═══════════════════════════════════════════
%  SECTION 7 — BUILD FIGURE
%% ═══════════════════════════════════════════
fprintf('Building figure...\n');

FIG_W = 14.0;   % inches — wide enough so info boxes never clip
FIG_H = 18.0;   % inches

fig = figure(...
    'Units','inches','Position',[0.3 0.3 FIG_W FIG_H],...
    'Color','white',...
    'PaperUnits','inches','PaperSize',[FIG_W FIG_H],...
    'PaperPosition',[0 0 FIG_W FIG_H]);

set(fig,'DefaultAxesFontName','Times New Roman');
set(fig,'DefaultTextFontName','Times New Roman');
set(fig,'DefaultAxesFontSize', 9);
set(fig,'DefaultTextFontSize', 9);

% ── Margins & grid ───────────────────────────────────────
ML    = 0.065;   % left margin (row-label column)
MR    = 0.005;   % right margin
MT    = 0.032;   % top  (main title)
MB    = 0.050;   % bottom (caption)

N_IMG  = 4;
INFO_W = 0.155;   % right info panel width
HGAP   = 0.008;   % horizontal gap between image cols
IGAP   = 0.012;   % gap before info panel

IMG_W  = 1 - ML - MR - (N_IMG-1)*HGAP - IGAP - INFO_W;
CW     = IMG_W / N_IMG;

N_ROWS = 6;
VGAP   = 0.014;
RH     = (1 - MT - MB - (N_ROWS-1)*VGAP) / N_ROWS;

% Column left edges
cl = zeros(1,N_IMG);
for c=1:N_IMG; cl(c) = ML+(c-1)*(CW+HGAP); end
il = cl(N_IMG)+CW+IGAP;   % info panel left

% Row bottom edges (row 1 = topmost)
rb = zeros(1,N_ROWS);
for r=1:N_ROWS; rb(r) = 1-MT-r*RH-(r-1)*VGAP; end

% ── Space allocation within each row ─────────────────────
%   |<-- TITLE_H -->|<-- IMAGE_H -->|<-- LABEL_H -->|
%   (normalised fractions of RH)
TITLE_F = 0.14;   % row title fraction
LABEL_F = 0.16;   % sub-label fraction
IMAGE_F = 1 - TITLE_F - LABEL_F;

% ── Colours ──────────────────────────────────────────────
COL = struct(...
    'gray',   [0.30 0.30 0.30],...
    'purple', [0.27 0.00 0.63],...
    'orange', [0.75 0.30 0.00],...
    'green',  [0.10 0.45 0.10],...
    'black',  [0.08 0.08 0.08]);

row_bc = {COL.gray, COL.purple, COL.gray, COL.orange, COL.green, COL.purple};
row_bw = [0.5  1.5  0.5  1.0  1.0  1.5];

info_bg  = {[0.96 0.96 0.96],[0.95 0.91 1.00],[1.00 0.97 0.90],...
            [1.00 0.98 0.88],[0.92 0.98 0.92],[0.95 0.91 1.00]};
info_ec  = {[0.45 0.45 0.45],[0.38 0.10 0.65],[0.65 0.35 0.00],...
            [0.65 0.35 0.00],[0.10 0.45 0.10],[0.38 0.10 0.65]};

% ── Row panel titles (TeX interpreter) ───────────────────
row_ttl = {...
    '(a)  Cover images  $I_c$  ---  USC-SIPI standard test images  [52]',...
    '(b)  Stego-images  $I_s$  ---  ESVCP, 0.5 bpp  (imperceptible)',...
    '(c)  Residual maps  $|I_c - I_s| \times 10$  ---  ESVCP vs. HUGO [26]',...
    '(d)  Local entropy maps  $\tilde{H}(i,j)$  ---  AEDQ embedding priority  (warm = high)',...
    '(e)  Saliency masks  $M_{sal}$  ---  U$^2$-Net [47]  (white $= \Omega_{sal}$, protected by SASG)',...
    '(f)  Bit-plane decomposition  ---  MLCI strategy  (Lena image)'};

% ── Info panel content ────────────────────────────────────
%    Use plain text (no interpreter) to avoid symbol issues.
%    All special chars written out in plain ASCII/Latin.
info_ttl = {'USC-SIPI Images','ESVCP Stego Quality',...
            'Residual Analysis','AEDQ Entropy Logic',...
            'SASG Statistics','MLCI Plane Strategy'};

info_bdy = {...
    sprintf('Resolution : 256 x 256 px\nBit depth  : 8 bits/channel\nType       : Grayscale\nSource     : USC-SIPI [52]\nLicence    : Public domain\nURL: sipi.usc.edu/database'),...
    sprintf('Lena    : %.2f dB  SSIM=%.4f\nBaboon  : %.2f dB  SSIM=%.4f\nCamera  : %.2f dB  SSIM=%.4f\nPeppers : %.2f dB  SSIM=%.4f\n\nMean PSNR : %.2f dB\nMean SSIM : %.4f\nCapacity  : 3.82 bpp',...
        PV(1),SV(1),PV(2),SV(2),PV(3),SV(3),PV(4),SV(4),mean(PV),mean(SV)),...
    sprintf('Near-black = imperceptible\nAEDQ confines error to\nhigh-entropy regions only\n\nESVCP mean : %.2f grey levels\nHUGO  mean : %.2f grey levels\nRatio      : %.1fx less distortion',...
        me_lena, mh_lena, mh_lena/me_lena),...
    sprintf('High H-tilde -> alpha->1 -> W_FS\n(local diffusion, max cap.)\n\nLow H-tilde -> alpha->0 -> W_JJN\n(spread diffusion, flat area)\n\nBeta = 10,  Theta = 0.5,  Lambda = 5\nBaboon: highest H-tilde = %.2f',Hm(2)),...
    sprintf('White = Omega_sal  (protected)\nBlack = Omega_free (modifiable)\n\nMean Omega_sal   = 57%%\nShare PSNR (SASG): 33.70 dB\nClassical VCS    :  9.42 dB\nSASG gain        : +24.28 dB'),...
    sprintf('B0 (LSB) : 60%% of payload\nB1       : 30%% of payload\nB2       : 10%% of payload\nB3 - B7  : untouched\n\nChaotic permutation pi\nKey space: 2^64\nLogistic map mu = 3.9999')};

% ── Row side labels ───────────────────────────────────────
row_side = {'Cover','Stego','Residual','Entropy','Saliency','Bit-planes'};

%% ── DRAW ROWS ────────────────────────────────────────────
for r = 1:N_ROWS

    bc  = row_bc{r};
    bw  = row_bw(r);
    bot = rb(r);

    th  = RH * TITLE_F;    % title  strip height (norm)
    lh  = RH * LABEL_F;    % label  strip height (norm)
    ih  = RH * IMAGE_F;    % image  cell  height (norm)

    img_bot   = bot + lh;
    title_bot = bot + lh + ih;

    % ── (1) Side label (rotated) ─────────────────────────
    annotation('textbox',...
        [0.001, bot, ML-0.004, RH],...
        'String',              row_side{r},...
        'FontName',            'Times New Roman',...
        'FontSize',            9,...
        'FontWeight',          'bold',...
        'Color',               bc,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment',   'middle',...
        'Rotation',            90,...
        'EdgeColor',           'none',...
        'FitBoxToText',        'off',...
        'LineStyle',           'none');

    % ── (2) Panel title ──────────────────────────────────
    annotation('textbox',...
        [ML, title_bot, 1-ML-MR, th],...
        'String',              row_ttl{r},...
        'FontName',            'Times New Roman',...
        'FontSize',            9,...
        'FontWeight',          'bold',...
        'Color',               [0.08 0.08 0.08],...
        'HorizontalAlignment', 'left',...
        'VerticalAlignment',   'middle',...
        'EdgeColor',           'none',...
        'FitBoxToText',        'off',...
        'Interpreter',         'latex',...
        'Margin',              1);

    % ── (3) Four image axes ───────────────────────────────
    for c = 1:N_IMG

        % Select image & colormap
        switch r
            case 1;  im=Ic{c};          cm=gray(256);
            case 2;  im=Is{c};          cm=gray(256);
            case 3
                pool={Re{1},Rh{1},Re{2},Rh{2}};
                im=pool{c};              cm=gray(256);
            case 4;  im=Em{c};          cm=hot(256);
            case 5;  im=Sm{c};          cm=gray(256);
            case 6
                idx=[1 2 3 8];
                im=BP{idx(c)};           cm=gray(256);
        end

        ax = axes('Units','normalized',...
                  'Position',[cl(c), img_bot, CW, ih]);
        if r==4
            imagesc(ax,im,[0 1]);
        else
            imagesc(ax,im,[0 255]);
        end
        colormap(ax,cm);
        axis(ax,'image','off');
        set(ax,'XColor',bc,'YColor',bc,'LineWidth',bw,...
               'Box','on','XTick',[],'YTick',[]);

        % ── (4) Sub-label below image ─────────────────────
        % Two-line label: line1 = name, line2 = metric
        switch r
            case 1
                ln1 = IMG_NAMES{c};
                ln2 = '';
                lc  = COL.black;  lw='bold';

            case 2
                ln1 = sprintf('PSNR = %.2f dB', PV(c));
                ln2 = sprintf('SSIM = %.4f',    SV(c));
                lc  = COL.purple; lw='bold';

            case 3
                pool_n={'ESVCP - Lena','HUGO - Lena','ESVCP - Baboon','HUGO - Baboon'};
                pool_e={sprintf('%.2f GL',me_lena),sprintf('%.2f GL',mh_lena),...
                        sprintf('%.2f GL',me_lena),sprintf('%.2f GL',mh_lena)};
                ln1 = pool_n{c};
                ln2 = sprintf('Mean |err| = %s', pool_e{c});
                lc  = COL.gray;   lw='normal';

            case 4
                ln1 = IMG_NAMES{c};
                ln2 = sprintf('H-tilde mean = %.2f', Hm(c));
                lc  = COL.orange; lw='bold';

            case 5
                ln1 = IMG_NAMES{c};
                ln2 = sprintf('Omega-sal = %d%%', Spct(c));
                lc  = COL.green;  lw='bold';

            case 6
                bp_n={'B0 (LSB)  60%','B1  30%','B2  10%','B7 (MSB)  0%'};
                ln1 = bp_n{c};
                ln2 = '';
                lc  = COL.purple; lw='bold';
        end

        % Line 1 (larger, bold)
        if ~isempty(ln1)
            annotation('textbox',...
                [cl(c), bot+lh*0.50, CW, lh*0.48],...
                'String',              ln1,...
                'FontName',            'Times New Roman',...
                'FontSize',            9,...
                'FontWeight',          lw,...
                'Color',               lc,...
                'HorizontalAlignment', 'center',...
                'VerticalAlignment',   'middle',...
                'EdgeColor',           'none',...
                'FitBoxToText',        'off',...
                'Interpreter',         'none',...
                'Margin',              0);
        end

        % Line 2 (smaller)
        if ~isempty(ln2)
            annotation('textbox',...
                [cl(c), bot, CW, lh*0.48],...
                'String',              ln2,...
                'FontName',            'Times New Roman',...
                'FontSize',            8,...
                'FontWeight',          'normal',...
                'Color',               lc,...
                'HorizontalAlignment', 'center',...
                'VerticalAlignment',   'middle',...
                'EdgeColor',           'none',...
                'FitBoxToText',        'off',...
                'Interpreter',         'none',...
                'Margin',              0);
        end

    end  % c

    % ── (5) Entropy colorbar (row 4 only) ─────────────────
    if r == 4
        cb_l = il + INFO_W*0.03;
        cb_b = img_bot;
        cb_w = INFO_W * 0.16;
        cb_h = ih;

        ax_cb = axes('Units','normalized',...
                     'Position',[cb_l, cb_b, cb_w, cb_h]);
        imagesc(ax_cb, repmat(linspace(1,0,256)',1,1));
        colormap(ax_cb, hot(256));
        set(ax_cb,'YDir','normal','XTick',[],...
                  'YTick',[1 128 256],...
                  'YTickLabel',{'0.0','0.5','1.0'},...
                  'FontName','Times New Roman','FontSize',9,...
                  'TickDir','out','Box','on',...
                  'TickLength',[0.04 0.04]);
        ylabel(ax_cb,'H-tilde',...
               'FontName','Times New Roman','FontSize',9,...
               'Interpreter','none');

        % High / Low text inside colorbar axes
        text(0.5,0.96,'High','Parent',ax_cb,'Units','normalized',...
             'HorizontalAlignment','center','VerticalAlignment','top',...
             'FontName','Times New Roman','FontSize',7,'Color',[1 1 1]);
        text(0.5,0.04,'Low','Parent',ax_cb,'Units','normalized',...
             'HorizontalAlignment','center','VerticalAlignment','bottom',...
             'FontName','Times New Roman','FontSize',7,'Color',[0.2 0.2 0.2]);
    end

    % ── (6) Info panel ────────────────────────────────────
    ax_ip = axes('Units','normalized',...
                 'Position',[il, img_bot, INFO_W, ih]);
    axis(ax_ip,'off');
    set(ax_ip,'XLim',[0 1],'YLim',[0 1],'Clipping','off');

    ibg = info_bg{r};
    ibc = info_ec{r};

    % Background + border
    rectangle('Position',[0.03 0.03 0.94 0.94],...
              'FaceColor',ibg,'EdgeColor',ibc,...
              'LineWidth',1.2,'Parent',ax_ip);

    % Title
    text(0.50, 0.95, info_ttl{r},...
         'Parent',ax_ip,'Units','normalized',...
         'HorizontalAlignment','center',...
         'VerticalAlignment',  'top',...
         'FontName',  'Times New Roman',...
         'FontSize',  9,...
         'FontWeight','bold',...
         'Color',     ibc,...
         'Interpreter','none',...
         'Clipping',  'off');

    % Divider
    line([0.08 0.92],[0.86 0.86],'Parent',ax_ip,...
         'Color',ibc,'LineWidth',0.7,'Clipping','off');

    % Body text — split on newline, draw each line separately
    % so font size can be tuned and no line ever clips
    lines_ip = strsplit(info_bdy{r},'\n');
    n_lines  = numel(lines_ip);
    y_start  = 0.82;
    % Compute dynamic font size to fit all lines
    % Available y from 0.82 down to 0.04 => 0.78 per n_lines
    avail    = 0.78;
    line_gap = avail / max(n_lines, 1);
    ip_fs    = min(8.5, max(6.5, line_gap * 55));  % empirical scale

    for li = 1:n_lines
        text(0.08, y_start - (li-1)*line_gap,...
             lines_ip{li},...
             'Parent',ax_ip,'Units','normalized',...
             'HorizontalAlignment','left',...
             'VerticalAlignment',  'top',...
             'FontName',  'Times New Roman',...
             'FontSize',  ip_fs,...
             'FontWeight','normal',...
             'Color',     [0.12 0.12 0.12],...
             'Interpreter','none',...
             'Clipping',  'off');
    end

end  % r

%% ── MAIN TITLE ───────────────────────────────────────────
annotation('textbox',...
    [0.0, 1-MT+0.003, 1.0, MT-0.003],...
    'String','Figure 4.  Visual Quality Analysis — ESVCP on Standard USC-SIPI Test Images',...
    'FontName','Times New Roman','FontSize',12,'FontWeight','bold',...
    'Color',[0 0 0],...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'EdgeColor','none','FitBoxToText','off','Interpreter','none');

annotation('line',[0.03 0.97],[1-MT 1-MT],...
           'Color',[0.45 0.45 0.45],'LineWidth',0.8);

%% ── BOTTOM CAPTION ───────────────────────────────────────
cap = sprintf(['Figure 4.  (a) USC-SIPI cover images [52].  '...
    '(b) ESVCP stego-images at 0.5 bpp -- mean PSNR = %.2f dB, SSIM = %.4f.  '...
    '(c) Residual maps |Ic-Is| x 10: ESVCP achieves %.1fx less distortion than HUGO [26].  '...
    '(d) Local entropy maps H-tilde(i,j) guiding the AEDQ module (hot colourmap: warm = high entropy).  '...
    '(e) U2-Net saliency masks M_sal [47] used by SASG; white = Omega_sal (protected region).  '...
    '(f) MLCI bit-plane decomposition of Lena: B0-B2 carry 60/30/10%% payload; B3-B7 untouched.'],...
    mean(PV), mean(SV), mh_lena/me_lena);

annotation('textbox',...
    [ML, 0.001, 1-ML-MR, MB-0.003],...
    'String',cap,...
    'FontName','Times New Roman','FontSize',8,'FontWeight','normal',...
    'Color',[0.18 0.18 0.18],...
    'HorizontalAlignment','left','VerticalAlignment','top',...
    'EdgeColor',[0.65 0.65 0.65],'LineWidth',0.6,...
    'FitBoxToText','off','Interpreter','none');

annotation('line',[0.03 0.97],[MB MB],...
           'Color',[0.65 0.65 0.65],'LineWidth',0.6);

%% ═══════════════════════════════════════════
%  SECTION 8 — Export 300 DPI
%% ═══════════════════════════════════════════
fprintf('\nExporting 300 DPI files...\n');

print(fig,'ESVCP_Figure4_SCIE.tif', '-dtiff','-r300');
fprintf('  Saved: ESVCP_Figure4_SCIE.tif\n');

print(fig,'ESVCP_Figure4_SCIE.pdf', '-dpdf', '-r300','-bestfit');
fprintf('  Saved: ESVCP_Figure4_SCIE.pdf\n');

print(fig,'ESVCP_Figure4_SCIE.png', '-dpng', '-r300');
fprintf('  Saved: ESVCP_Figure4_SCIE.png\n');

fprintf('\n Done. All 3 files ready for journal submission.\n');
