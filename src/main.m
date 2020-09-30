global DATA_PATH = "../data/";
global OUTPUT_PATH = "../out/";

im_file = [DATA_PATH "ex.jpg"];
Yini = single(imread(im_file));
ltot = size(Yini, 1);
ctot = size(Yini, 2);
trois = size(Yini, 3);

#image(uint8(Yini));
#title('image initiale');
#axis equal;

# X : (ltot,ctot)*3
X = reshape(Yini,ltot*ctot, trois);
Yfin = reshape(X, ltot, ctot, 3);

nl = 5;
l = floor(ltot/nl);

# 1,2
function [P, E, Ip] = codeur_ACP(X, p)
  m = mean(X);
  e = std(X);
  X = (X - m) ./ e;
  n = size(X, 1)
  V = (X.') * X ./ (n-1);
  [E, D] = eig(V);

  # Sort 
  [~, idx] = sort(diag(D), 'descend');
  D = D(idx, idx);
  E = E(:, idx);
  Itot = sum(diag(D));
  Ip = diag(D)*100./Itot;
  P = X*E;
  
endfunction

  
  
  