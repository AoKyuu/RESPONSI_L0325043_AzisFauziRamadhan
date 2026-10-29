% =========================================================================
%  RESPONSI METODE NUMERIK - KASUS 3
%  Topik  : Persamaan Non-Linear Pencarian Jari-Jari Bola & Tabung
%  Metode : 1. Penentuan Interval Awal dengan Metode Grafik
%           2. Metode Biseksi (Bisection Method)
%           3. Metode Regula-Falsi (False Position Method)
% =========================================================================

clear; clc; close all;

% -------------------------------------------------------------------------
% 1. PARAMETER FISIS & PERUMUSAN PERSAMAAN NON-LINEAR
% -------------------------------------------------------------------------
% Diketahui:
%   Tinggi tabung: t = 2r (bola tepat menyinggung dasar dan tutup tabung)
%   Volume bola:   V_bola = (4/3) * pi * r^3 = 300 cm^3
%
% Perbandingan Volume:
%   V_bola / V_tabung = [(4/3) * pi * r^3] / [pi * r^2 * (2r)] = 4 / 6 = 2 / 3
%   V_tabung = (3/2) * V_bola = 1.5 * 300 = 450 cm^3
%   V_luar   = V_tabung - V_bola = 450 - 300 = 150 cm^3 (sesuai rumus V = (2/3)*pi*r^3)
%
% Persamaan Non-Linear f(r) = 0:
%   f(r) = (4/3) * pi * r^3 - 300 = 0
% -------------------------------------------------------------------------

V_bola_target = 300; % cm^3
f = @(r) (4/3) * pi * (r.^3) - V_bola_target;

% Nilai eksak sebagai referensi analitik: r = (300 * 3 / (4 * pi))^(1/3)
r_eksak = (V_bola_target * 3 / (4 * pi))^(1/3);

fprintf('=========================================================================\n');
fprintf('  KASUS 3: PENCARIAN JARI-JARI BOLA DAN TABUNG (PERSAMAAN NON-LINEAR)\n');
fprintf('=========================================================================\n');
fprintf('  Volume Bola Diketahui (V_bola)   = %.2f cm^3\n', V_bola_target);
fprintf('  Volume Tabung (V_tabung)         = %.2f cm^3\n', 1.5 * V_bola_target);
fprintf('  Volume Tabung di Luar Bola (V)   = %.2f cm^3\n', 0.5 * V_bola_target);
fprintf('  Bentuk Persamaan Non-Linear      : f(r) = (4/3)*pi*r^3 - 300 = 0\n');
fprintf('  Solusi Eksak Matematika          : r = %.6f cm\n', r_eksak);
fprintf('=========================================================================\n\n');

% -------------------------------------------------------------------------
% 2. METODE GRAFIK UNTUK PENENTUAN INTERVAL AWAL [a, b]
% -------------------------------------------------------------------------
r_plot = linspace(1, 6, 500);
f_plot = f(r_plot);

figure('Name', 'Kasus 3 - Metode Grafik Penentuan Interval Awal', ...
       'NumberTitle', 'off', 'Position', [100, 100, 750, 450]);

plot(r_plot, f_plot, 'b-', 'LineWidth', 2.0, 'DisplayName', 'f(r) = \frac{4}{3}\pi r^3 - 300');
hold on;
plot([1, 6], [0, 0], 'k--', 'LineWidth', 1.2, 'DisplayName', 'Garis f(r) = 0');

% Tandai titik potong pada grafik
plot(r_eksak, 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
     'DisplayName', sprintf('Akar Eksak r \\approx %.4f cm', r_eksak));

% Tandai batas tebakan awal a = 4 dan b = 5
a_awal = 4.0;
b_awal = 5.0;
plot([a_awal, a_awal], [-300, f(a_awal)], 'm:', 'LineWidth', 1.5, 'DisplayName', 'Batas Bawah a = 4');
plot([b_awal, b_awal], [-300, f(b_awal)], 'g:', 'LineWidth', 1.5, 'DisplayName', 'Batas Atas b = 5');

xlabel('Jari-jari  r  (cm)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Nilai Fungsi  f(r)', 'FontSize', 11, 'FontWeight', 'bold');
title({'Metode Grafik: Penentuan Interval Awal Akar Persamaan Non-Linear'; ...
       'Kurva memotong sumbu-x di antara r = 4 cm dan r = 5 cm'}, 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 10);
grid on;
ylim([-350, 600]);

fprintf('--- HASIL EVALUASI METODE GRAFIK ---\n');
fprintf('  Dipilih batas bawah a = %.2f  -->  f(a) = %10.4f\n', a_awal, f(a_awal));
fprintf('  Dipilih batas atas  b = %.2f  -->  f(b) = %10.4f\n', b_awal, f(b_awal));
fprintf('  Uji tanda: f(a) * f(b) = %.4f < 0  --> Terbukti memuat akar di interval [%.1f, %.1f]\n\n', ...
        f(a_awal) * f(b_awal), a_awal, b_awal);

% -------------------------------------------------------------------------
% 3. EKSEKUSI METODE BISEKSI
% -------------------------------------------------------------------------
toleransi = 1e-6;
max_iter  = 50;

fprintf('=========================================================================\n');
fprintf('  EKSEKUSI METODE BISEKSI (Toleransi = %.0e)\n', toleransi);
fprintf('=========================================================================\n');
fprintf('  %-5s | %-10s | %-10s | %-10s | %-13s | %-11s\n', ...
        'Iter', 'a', 'b', 'c (Akar)', 'f(c)', 'Galat Aproks');
fprintf('  %s\n', repmat('-', 1, 71));

a = a_awal;
b = b_awal;
iter_biseksi = 0;
riwayat_c_bis = [];
riwayat_err_bis = [];

while iter_biseksi < max_iter
    iter_biseksi = iter_biseksi + 1;
    c = (a + b) / 2;
    fc = f(c);
    err = abs(b - a) / 2;

    riwayat_c_bis(iter_biseksi) = c;
    riwayat_err_bis(iter_biseksi) = err;

    fprintf('  %4d  | %9.6f  | %9.6f  | %9.6f  | %+12.4e  | %10.4e\n', ...
            iter_biseksi, a, b, c, fc, err);

    if abs(fc) < toleransi || err < toleransi
        break;
    end

    if f(a) * fc < 0
        b = c;
    else
        a = c;
    end
end
r_biseksi = c;
fprintf('  %s\n', repmat('-', 1, 71));
fprintf('  => Biseksi Konvergen pada iterasi ke-%d: r = %.6f cm\n\n', iter_biseksi, r_biseksi);

% -------------------------------------------------------------------------
% 4. EKSEKUSI METODE REGULA-FALSI (FALSE POSITION)
% -------------------------------------------------------------------------
fprintf('=========================================================================\n');
fprintf('  EKSEKUSI METODE REGULA-FALSI (Toleransi = %.0e)\n', toleransi);
fprintf('=========================================================================\n');
fprintf('  %-5s | %-10s | %-10s | %-10s | %-13s | %-11s\n', ...
        'Iter', 'a', 'b', 'c (Akar)', 'f(c)', 'Galat Aproks');
fprintf('  %s\n', repmat('-', 1, 71));

a = a_awal;
b = b_awal;
iter_rf = 0;
c_lama = a;
riwayat_c_rf = [];
riwayat_err_rf = [];

while iter_rf < max_iter
    iter_rf = iter_rf + 1;
    fa = f(a);
    fb = f(b);

    % Rumus interpolasi linear Regula-Falsi
    c = b - fb * (b - a) / (fb - fa);
    fc = f(c);

    if iter_rf == 1
        err = abs(b - a);
    else
        err = abs(c - c_lama);
    end
    c_lama = c;

    riwayat_c_rf(iter_rf) = c;
    riwayat_err_rf(iter_rf) = err;

    fprintf('  %4d  | %9.6f  | %9.6f  | %9.6f  | %+12.4e  | %10.4e\n', ...
            iter_rf, a, b, c, fc, err);

    if abs(fc) < toleransi || err < toleransi
        break;
    end

    if fa * fc < 0
        b = c;
    else
        a = c;
    end
end
r_rf = c;
fprintf('  %s\n', repmat('-', 1, 71));
fprintf('  => Regula-Falsi Konvergen pada iterasi ke-%d: r = %.6f cm\n\n', iter_rf, r_rf);

% -------------------------------------------------------------------------
% 5. REKAPITULASI HASIL & PERHITUNGAN DIMENSI DAN VOLUME GEOMETRI
% -------------------------------------------------------------------------
r_final = r_rf; % Menggunakan solusi yang diperoleh
t_final = 2 * r_final;
V_bola_hitung   = (4/3) * pi * (r_final^3);
V_tabung_hitung = pi * (r_final^2) * t_final;
V_luar_hitung   = V_tabung_hitung - V_bola_hitung;

fprintf('=========================================================================\n');
fprintf('  REKAPITULASI HASIL AKHIR DAN DIMENSI BANGUN RUANG\n');
fprintf('=========================================================================\n');
fprintf('  Jari-jari bola & tabung (r)      = %10.6f cm\n', r_final);
fprintf('  Tinggi tabung (t = 2r)           = %10.6f cm\n', t_final);
fprintf('  Volume Bola Terhitung            = %10.4f cm^3 (Target: 300 cm^3)\n', V_bola_hitung);
fprintf('  Volume Tabung Terhitung          = %10.4f cm^3\n', V_tabung_hitung);
fprintf('  Volume Tabung di Luar Bola       = %10.4f cm^3\n', V_luar_hitung);
fprintf('  Perbandingan Kecepatan Konvergensi:\n');
fprintf('    - Metode Biseksi      : %d iterasi\n', iter_biseksi);
fprintf('    - Metode Regula-Falsi : %d iterasi\n', iter_rf);
fprintf('=========================================================================\n');

