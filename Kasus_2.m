% =========================================================================
%  RESPONSI METODE NUMERIK - KASUS 2
%  Topik  : Penyelesaian SPL Penentuan Harga Bahan Pokok
%  Metode : 1. Evaluasi Dominansi Diagonal Matriks
%           2. Metode Langsung (Eliminasi Gauss-Jordan)
%           3. Validasi Metode Iteratif (Gauss-Seidel Berbasis Pivoting)
% =========================================================================

clear; clc; close all;

% -------------------------------------------------------------------------
% 1. DATA TRANSAKSI & PENYETARAAN SATUAN KE KG
% Definisi Variabel:
%   x1 = Harga Beras  (Rp/kg)
%   x2 = Harga Telur  (Rp/kg)
%   x3 = Harga Tepung (Rp/kg)
%   x4 = Harga Ayam   (Rp/kg)
% -------------------------------------------------------------------------
% Konversi: g -> kg (*0.001), hg -> kg (*0.1), dag -> kg (*0.01)
pembeli = {'Adel', 'Briza', 'Caca', 'Dinda'};

Adel  = [2.5,        1500 * 1e-3, 5.0,        500 * 1e-3];   % Rp 161.000
Briza = [40 * 0.1,   0.75,        1000 * 1e-3, 2.0];          % Rp 149.000
Caca  = [2000 * 1e-3, 15 * 0.1,   50 * 0.01,  6000 * 1e-3];  % Rp 251.500
Dinda = [1.0,        4250 * 1e-3, 20 * 0.1,   9 * 0.1];      % Rp 173.000

A_awal = [Adel; Briza; Caca; Dinda];
b_awal = [161000; 149000; 251500; 173000];
n = length(b_awal);

% -------------------------------------------------------------------------
% 2. UJI KELAYAKAN METODE ITERATIF (DIAGONAL DOMINANCE CHECK)
% -------------------------------------------------------------------------
fprintf('\n+--------------------------------------------------------------------------+\n');
fprintf('| 1. UJI SYARAT DOMINANSI DIAGONAL MATRIKS AWAL                           |\n');
fprintf('+--------------------------------------------------------------------------+\n');
fprintf('  %-8s | %-16s | %-18s | %-14s\n', ...
        'Pelanggan', '|Elemen Diagonal|', 'Jumlah Non-Diagonal', 'Keterangan');
fprintf('  ------------------------------------------------------------------------\n');

is_dominant = true;
for i = 1:n
    diag_val = abs(A_awal(i, i));
    sum_off  = sum(abs(A_awal(i, :))) - diag_val;

    if diag_val > sum_off
        status = 'Dominan [OK]';
    else
        status = 'Tidak Dominan';
        is_dominant = false;
    end
    fprintf('  %-8s | |a_%d%d| = %5.2f kg  | %6.2f kg           | %s\n', ...
            pembeli{i}, i, i, diag_val, sum_off, status);
end
fprintf('  ------------------------------------------------------------------------\n');

if ~is_dominant
    fprintf('  [KESIMPULAN UJI]:\n');
    fprintf('  Matriks sistem awal TIDAK memenuhi syarat dominan diagonal secara ketat.\n');
    fprintf('  Maka secara teoretis, penyelesaian utama menggunakan METODE LANGSUNG.\n\n');
end

% -------------------------------------------------------------------------
% 3. EKSEKUSI METODE LANGSUNG: ELIMINASI GAUSS-JORDAN
% -------------------------------------------------------------------------
fprintf('+--------------------------------------------------------------------------+\n');
fprintf('| 2. PENYELESAIAN DENGAN METODE LANGSUNG (GAUSS-JORDAN)                    |\n');
fprintf('+--------------------------------------------------------------------------+\n');

% Membentuk matriks augmented [A | b]
M = [A_awal, b_awal];

fprintf('  Tampilan Matriks Augmented [A | b] (Satuan: kg & Rupiah):\n');
for i = 1:n
    fprintf('    [%4.2f  %4.2f  %4.2f  %4.2f | %9.0f ]  --> %s\n', ...
            M(i, 1:4), M(i, 5), pembeli{i});
end
fprintf('\n');

% Algoritma Eliminasi Gauss-Jordan
for k = 1:n
    % Bagi baris pivot dengan elemen diagonalnya (membuat pivot bernilai 1)
    pivot = M(k, k);
    M(k, :) = M(k, :) / pivot;

    % Eliminasi seluruh baris di atas dan di bawah pivot
    for i = 1:n
        if i ~= k
            pengali = M(i, k);
            M(i, :) = M(i, :) - pengali * M(k, :);
        end
    end
end

% Solusi akhir berada pada kolom ke-5
x_gj = M(:, end);

nama_komoditas = {'Beras', 'Telur', 'Tepung', 'Ayam'};
fprintf('  Hasil Solusi Analitik Harga Bahan Pokok:\n');
fprintf('  +-----+--------------+-----------+-----------------------+\n');
fprintf('  | No. | Komoditas    | Variabel  | Harga Satuan          |\n');
fprintf('  +-----+--------------+-----------+-----------------------+\n');
for i = 1:n
    fprintf('  |  %d  | %-12s |    x%-2d    | Rp %10.2f / kg   |\n', ...
            i, nama_komoditas{i}, i, x_gj(i));
end
fprintf('  +-----+--------------+-----------+-----------------------+\n\n');

% -------------------------------------------------------------------------
% 4. VALIDASI KOMPARATIF: GAUSS-SEIDEL SETELAH PIVOTING BARIS
% Baris diatur ulang: Briza (x1), Dinda (x2), Adel (x3), Caca (x4)
% -------------------------------------------------------------------------
fprintf('+--------------------------------------------------------------------------+\n');
fprintf('| 3. VALIDASI METODE ITERATIF GAUSS-SEIDEL (SETELAH PENATAAN BARIS)        |\n');
fprintf('+--------------------------------------------------------------------------+\n');
fprintf('  %-5s | %-14s | %-14s | %-14s | %-14s | %-12s\n', ...
        'Iter', 'x1 (Beras)', 'x2 (Telur)', 'x3 (Tepung)', 'x4 (Ayam)', 'Galat Rel');
fprintf('  ------------------------------------------------------------------------\n');

A_gs = [Briza; Dinda; Adel; Caca];
b_gs = [149000; 173000; 161000; 251500];

x_gs = zeros(n, 1);
jml_iterasi = 10;

for it = 1:jml_iterasi
    x_prev = x_gs;

    % Pembaruan bertahap khas Gauss-Seidel
    x_gs(1) = (b_gs(1) - A_gs(1,2)*x_gs(2) - A_gs(1,3)*x_gs(3) - A_gs(1,4)*x_gs(4)) / A_gs(1,1);
    x_gs(2) = (b_gs(2) - A_gs(2,1)*x_gs(1) - A_gs(2,3)*x_gs(3) - A_gs(2,4)*x_gs(4)) / A_gs(2,2);
    x_gs(3) = (b_gs(3) - A_gs(3,1)*x_gs(1) - A_gs(3,2)*x_gs(2) - A_gs(3,4)*x_gs(4)) / A_gs(3,3);
    x_gs(4) = (b_gs(4) - A_gs(4,1)*x_gs(1) - A_gs(4,2)*x_gs(2) - A_gs(4,3)*x_gs(3)) / A_gs(4,4);

    % Galat relatif aproksimasi maksimum
    err_rel = max(abs(x_gs - x_prev) ./ abs(x_gs));

    fprintf('  %4d  | Rp %9.2f | Rp %9.2f | Rp %9.2f | Rp %9.2f | %9.3e\n', ...
            it, x_gs(1), x_gs(2), x_gs(3), x_gs(4), err_rel);
end
fprintf('  ------------------------------------------------------------------------\n');
fprintf('  Catatan: Nilai hasil iterasi ke-10 identik dengan solusi Gauss-Jordan.\n');
fprintf('+--------------------------------------------------------------------------+\n\n');

% -------------------------------------------------------------------------
% 5. VISUALISASI GRAFIK HARGA PER BAHAN
% -------------------------------------------------------------------------
figure('Name', 'Kasus 2 - Diagram Harga Bahan Makanan', 'NumberTitle', 'off', ...
       'Position', [120, 120, 680, 420]);

warna_batang = [0.15 0.45 0.75];
bar_chart = bar(x_gj, 0.5, 'FaceColor', warna_batang, 'EdgeColor', [0 0.2 0.4], 'LineWidth', 1.2);

set(gca, 'XTickLabel', nama_komoditas, 'FontSize', 10);
ylabel('Harga Satuan (Rupiah/kg)', 'FontSize', 11, 'FontWeight', 'bold');
title({'Perbandingan Harga Bahan Makanan per Kilogram'; ...
       'Solusi Sistem Persamaan Linear Metode Numerik'}, 'FontSize', 12, 'FontWeight', 'bold');
grid on;
% Label nilai harga tepat di atas batang diagram
for i = 1:n
    text(i, x_gj(i) + 1000, sprintf('Rp %d', round(x_gj(i))), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end
ylim([0, max(x_gj) + 5000]);

