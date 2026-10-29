%  KASUS 1 : VISUALISASI GELOMBANG AIR LAUT
%  Galat & Error Pemotongan - Deret Taylor

clear; clc; close all;

% BAGIAN 1 : DEFINISI PARAMETER

lambda = 12;            % Panjang gelombang (lambda)
v      = 36;            % Kecepatan rambat gelombang
x      = 10;            % Nilai x pada fungsi e^x (konstan terhadap t)
h0     = 5;             % Konstanta amplitudo gelombang
n_list = [23, 24, 25];  % Tiga batas iterasi deret Taylor yang diuji

% Buat vektor waktu t dari 0 hingga 5 (500 titik diskret)
t = linspace(0, 5, 500);

% Argumen fungsi cosinus: u = tv/lambda = 36t/12 = 3t (berubah tiap t)
u = t .* v ./ lambda;

% BAGIAN 2 : NILAI EKSAK - f_eksak
% Menggunakan fungsi bawaan Octave: cos() dan exp()

h_eksak = h0 .* (cos(u) + exp(x));

% BAGIAN 3 : PENDEKATAN DERET TAYLOR - f_{n=23}, f_{n=24}, f_{n=25}

%  Rumus deret Taylor cos(u):
%    cos(u) = SUM_{k=0}^{n-1}  [(-1)^k * u^(2k)] / (2k)!
%
%  Rumus deret Taylor e^x:
%    e^x    = SUM_{k=0}^{n-1}  x^k / k!
%
%  n = jumlah total suku yang dihitung (batas iterasi)

% Matriks penyimpan hasil pendekatan: 3 baris (n=23,24,25) x 500 kolom
h_approx = zeros(3, length(t));

for idx = 1:3
    n = n_list(idx);    % Pilih nilai n saat ini

    % ----- Pendekatan cos(u) dengan Deret Taylor -----
    cos_taylor = zeros(1, length(t));   % Inisialisasi akumulator
    for k = 0:(n-1)
        % Suku ke-k : (-1)^k * u^(2k) / (2k)!
        suku_cos   = ((-1)^k .* u.^(2*k)) ./ factorial(2*k);
        cos_taylor = cos_taylor + suku_cos;
    end

    % ----- Pendekatan e^x dengan Deret Taylor -----
    % x = 10 adalah konstan -> hasilnya skalar tunggal
    exp_taylor = 0;
    for k = 0:(n-1)
        % Suku ke-k : x^k / k!
        suku_exp   = x^k / factorial(k);
        exp_taylor = exp_taylor + suku_exp;
    end

    % ----- Gabungkan menjadi h pendekatan -----
    h_approx(idx, :) = h0 .* (cos_taylor + exp_taylor);
end

% BAGIAN 4 : PLOT PERBANDINGAN KEEMPAT FUNGSI
% Semua fungsi digambarkan dalam satu grafik yang sama
figure('Name', 'Kasus 1 - Gelombang Air Laut (Deret Taylor)', ...
       'NumberTitle', 'off', 'Position', [100 100 900 500]);

plot(t, h_eksak,         'k-',  'LineWidth', 2.5, 'DisplayName', 'f_{eksak}');
hold on;
plot(t, h_approx(1, :), 'r--', 'LineWidth', 1.8, 'DisplayName', 'f_{n=23}');
plot(t, h_approx(2, :), 'b-.', 'LineWidth', 1.8, 'DisplayName', 'f_{n=24}');
plot(t, h_approx(3, :), 'm:',  'LineWidth', 2.2, 'DisplayName', 'f_{n=25}');
hold off;

xlabel('Waktu  t  (0 \leq t \leq 5)', 'FontSize', 12);
ylabel('Ketinggian Gelombang  h(t)',   'FontSize', 12);
title({'Kasus 1 - Visualisasi Gelombang Air Laut'; ...
       'Perbandingan f_{eksak} vs Pendekatan Deret Taylor (n = 23, 24, 25)'}, ...
      'FontSize', 13);
legend('f_{eksak}', 'f_{n=23}', 'f_{n=24}', 'f_{n=25}');
grid on;

% BAGIAN 5 : ANALISIS GALAT MUTLAK RATA-RATA
% Galat mutlak tiap titik : |h_eksak - h_approx|
% Rerata galat mutlak     : mean(|h_eksak - h_approx|)
% Galat relatif rata-rata : [rerata galat / mean(|h_eksak|)] x 100%

fprintf('\n=================================================================\n');
fprintf('          ANALISIS GALAT MUTLAK RATA-RATA  -  KASUS 1\n');
fprintf('=================================================================\n');
fprintf('  Parameter : lambda=%d, v=%d, x=%d, h0=%d\n', lambda, v, x, h0);
fprintf('  Toleransi Error yang Ditetapkan : 1%%\n');
fprintf('-----------------------------------------------------------------\n');

toleransi = 1.0;

for idx = 1:3
    n = n_list(idx);
    galat_abs_tiap = abs(h_eksak - h_approx(idx, :));   % galat per titik
    galat_mean     = mean(galat_abs_tiap);               % rerata galat mutlak
    galat_relatif  = (galat_mean / mean(abs(h_eksak))) * 100;  % dalam %

    if galat_relatif <= toleransi
        status = 'LAYAK      [v]';
    else
        status = 'TIDAK LAYAK [x]';
    end

    fprintf('  n = %d:\n', n);
    fprintf('    Galat Mutlak Rata-rata = %.6e\n', galat_mean);
    fprintf('    Galat Relatif          = %.8f%%\n', galat_relatif);
    fprintf('    Kelayakan              : %s\n\n', status);
end

fprintf('=================================================================\n');
fprintf('Nilai Referensi:\n');
fprintf('  exp(10)            = %.6f\n', exp(x));
fprintf('  cos(u) saat t=0    = %.6f  (u=0)\n',  cos(0));
fprintf('  cos(u) saat t=5    = %.6f  (u=15)\n', cos(5*v/lambda));
fprintf('  h_eksak saat t=0   = %.4f\n', h0*(cos(0)+exp(x)));
fprintf('  h_eksak saat t=5   = %.4f\n', h0*(cos(5*v/lambda)+exp(x)));
fprintf('=================================================================\n');
