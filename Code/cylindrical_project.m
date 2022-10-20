function I_project = cylindrical_project(I, f)

[h w ch] = size(I);
xc = floor(w/2);
yc = floor(h/2);

[X Y] = meshgrid(-xc:xc, -yc:yc);
X_prime = f .* atan(X ./ f) +xc;
Y_prime = Y ./ cos(X ./ f) + yc;

I_project = zeros(size(X_prime, 1), size(X_prime, 2), ch);

for i = 1:ch,
    I_project(:, :, i) = interp2(I(:,:,i), X_prime, Y_prime);
end
I_project(isnan(I_project)) = 0;
end