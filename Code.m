pkg load symbolic; % Load symbolic package for Bessel functions

% Constants
c = 3e8; % Speed of light in vacuum (m/s)
a = 0.05; % Radius of the circular waveguide (meters)
mu0 = 4 * pi * 1e-7; % Permeability of free space (H/m)
epsilon0 = 8.854e-12; % Permittivity of free space (F/m)

% Function to find the first zero of the Bessel function
function zero = bessel_zero(m, n, type)
  if type == 0 % For TM mode
    f = @(x) besselj(m, x);
  else % For TE mode
    f = @(x) besselj(m, x) * cos(n * pi) + (m / x) * besselj(m - 1, x);
  end

  % Iterate to find the first zero
  zero_found = false;
  x = 0.1; % Start near zero
  while ~zero_found && x < 20
    % Check sign change
    if f(x) * f(x + 0.1) < 0
      zero = fzero(f, [x, x + 0.1]);
      zero_found = true;
    end
    x += 0.1; % Increment x
  end

  if ~zero_found
    error("No zero found for Bessel function.");
  end
end

% Select the mode numbers for TE and TM
m = 1; % Radial mode number
n = 1; % Azimuthal mode number

% Calculate cutoff frequencies for TE and TM modes
jmn_TE = bessel_zero(m, n, 1); % TE mode
jmn_TM = bessel_zero(m, n, 0); % TM mode

fc_TE = (jmn_TE * c) / (2 * pi * a); % Cutoff frequency for TE mode
fc_TM = (jmn_TM * c) / (2 * pi * a); % Cutoff frequency for TM mode

% Display cutoff frequencies
printf("Cutoff frequency for TE mode (m=%d, n=%d): %.2f GHz\n", m, n, fc_TE / 1e9);
printf("Cutoff frequency for TM mode (m=%d, n=%d): %.2f GHz\n", m, n, fc_TM / 1e9);

% Visualization of the field distribution (TE mode)
theta = linspace(0, 2 * pi, 100);
r = linspace(0, a, 50);
[R, T] = meshgrid(r, theta);

% TE mode field distribution
E_TE = besselj(m, jmn_TE * R / a) .* cos(n * T);

% Plot TE mode
figure;
subplot(1, 2, 1);
surf(R .* cos(T), R .* sin(T), E_TE);
title('TE Mode Field Distribution');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('E Field');
view(45, 30);
grid on;

% TM mode field distribution
H_TM = besselj(m, jmn_TM * R / a) .* sin(n * T);

% Plot TM mode
subplot(1, 2, 2);
surf(R .* cos(T), R .* sin(T), H_TM);
title('TM Mode Field Distribution');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('H Field');
view(45, 30);
grid on;
