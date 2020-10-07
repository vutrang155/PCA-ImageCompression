# Global Variables
global DATA_PATH = "../data/";
global OUTPUT_PATH = "../out/";

# Init
im_file = [DATA_PATH "ex.jpg"];
Yini = single(imread(im_file));
ltot = size(Yini, 1);
ctot = size(Yini, 2);
trois = size(Yini, 3);

# Plotting image
#image(uint8(Yini));
#title('image initiale');
#axis equal;

# Reshaping Y(ltot, ctot, 3) -> Y(ltot*ctot, 3)
X = reshape(Yini,ltot*ctot, trois);


nl =4; # block
l = floor(ltot/nl); # lines in 1 block
nc = nl * ctot / ltot;
if mod(nc,1)
  nc = floor(nc) + 1;
end
c = floor(ctot/nc); # columns in 1 block

# Encoding image X
function [P, E, Ip] = codeur_ACP(X, p)
  #m = mean(X);
  #e = std(X);
  #X = (X - m) ./ e;
  
  n = size(X, 1);
  #V = (X.') * X ./ (n-1); # var-covar matrix
  V = X*(X.') ./ (n-1);
  [E, D] = eig(V); 

  # Sort 
  [~, idx] = sort(diag(D), 'descend');
  D = D(idx, idx);
  E = E(:, idx);
  Itot = sum(diag(D));
  Ip = diag(D)*100./Itot;
  #X = X.*e + m;
  P = X*E;
  Ip = Ip(1:p);
  P = P(:, 1:p);
  E = E(:, 1:p);
  
endfunction

# Decoding image X 
function X = decodeur_ACP(P, E)
  X = P*E.';
endfunction

# Compressing with block
 p =1
  Yfin = zeros(ltot,ctot,3);
  Ips = zeros(nl*nc, 1);
  it = 1;
  for i = 0:nl-1
    for j = 0:nc-1
      # Indexes for bloc (i,j)
      idl = [l*i+1:l*i+l];
      idc = [c*j+1:c*j+l];
      if i == nl-1
        idl = [l*i+1:ltot];
      end
      if j == nc-1
        idc = [c*j+1:ctot];
      end
      lt = size(idl,2); # Total lines of block (i,j)
      ct = size(idc,2); # Total columns of block (i,j)
      
      # Compression - Decompression
      X = reshape(Yini(idl, idc,:), lt*ct, trois);
      m = mean(X);
      X = X - m;
      [P, E, Ip] = codeur_ACP(X, p);
      X = decodeur_ACP(P, E) + m;
      
      # Compute Information
      Ips(it,1) = sum(Ip(1:p,:)); 
      it = it + 1;
      
      # Rematch Yb with Y
      Yb = reshape(X, lt,ct,3);
      Yfin(idl,idc,:) = Yb;
    end
  end

  figure(p)
  image(uint8(Yfin))
  str = sprintf("p = %d",p);
  title(str)
  axis equal;
