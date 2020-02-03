function y = ventriclefitnessfcn(x,C)
Nx = sum(x);    % total number of regions selected
Cx = x.*C;
Cx(Cx == 0) = 1;
y = -(Nx*prod(Cx));
end