# Global Variables
global DATA_PATH = "../data/";
global OUTPUT_PATH = "../out/";

# Init
im_file = [DATA_PATH "Mars_Path_Finder.jpg"];
Yini = rgb2gray(single(imread(im_file)));
ltot = size(Yini, 1);
ctot = size(Yini, 2);

imshow(uint8(Yini));
title('image initiale');
axis equal;

nl = 10; # block
l = floor(ltot/nl); # lines in 1 block
nc = nl * ctot / ltot;
if mod(nc,1)
  nc = floor(nc) + 1;
end
c = floor(ctot/nc); # columns in 1 block



# Compressing with block
for p = 1:3
  blocs_envoyes = 0;
  Yfin = zeros(ltot,ctot);
  Ips = zeros(nl*nc, 1);
  it = 1;
  for i = 0:nl-1
    for j = 0:nc-1
      # Indexes for bloc (i,j)
      idl = [l*i+1:l*i+l];
      idc = [c*j+1:c*j+c];
      if i == nl-1
        idl = [l*i+1:ltot];
      end
      if j == nc-1
        idc = [c*j+1:ctot];
      end
      lt = size(idl,2); # Total lines of block (i,j)
      ct = size(idc,2); # Total columns of block (i,j)
      
      # Compression - Decompression
      X = reshape(Yini(idl, idc), lt,ct);
      m = mean(X); e = std(X);
      for ie = 1:size(e,2)
        if e(1,ie) == 0
          e(1, ie) = 1;
        endif
      endfor
      
      X_centralise = (X - m) ./ e; 
      [P, E, Ip] = codeur_ACP(X_centralise, p);

      # Calcul de pourcentage 
      X = decodeur_ACP(P, E).*e + m;
      
      # Compute Information
      Ips(it,1) = sum(Ip(1:p,:)); 
      it = it + 1;
      
      # Rematch Yb with Y
      Yb = reshape(X, lt,ct);
      Yfin(idl,idc) = Yb;
      
      # Blocs totals envoyes
      blocs_envoyes = blocs_envoyes + numel(P);
    end
    
  end

  figure(p+1)
  imshow(uint8(Yfin));
  bits_envoyes = blocs_envoyes/numel(Yini);
  str = sprintf("p = %d ; mean(I) = %.1f ; bits envoyé = %.2f",p,mean(Ips),bits_envoyes);
  title(str);
  
  axis equal;
end

