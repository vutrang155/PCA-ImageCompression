# Global Variables
global DATA_PATH = "../data/";
global OUTPUT_PATH = "../out/";

# Init
im_file = [DATA_PATH "Mars_Path_Finder.jpg"];
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

# Defining number of blocks per width/height
nl = 1; # block
l = floor(ltot/nl); # number of lines in 1 block
nc = nl * ctot / ltot;
if mod(nc,1) 
  nc = floor(nc) + 1;
end
c = floor(ctot/nc); # number of columns in 1 block

# Compressing 
for p = 1:3
  blocs_envoyes = 0; # Sent rate
  Yfin = zeros(ltot,ctot,3); # Final image for p
  Ips = zeros(nl*nc, 1); # Informations of each block
  it = 1; # Iteration for computing Ips
  # Iterate from block to block
  for i = 0:nl-1
    for j = 0:nc-1
      # Determine indexes for the block (i,j)
      idl = [l*i+1:l*i+l]; # <=> Local position of block (i,j) : [1;l]
      idc = [c*j+1:c*j+c]; # <=> Local position of block (i,j) : [1,c], where l and c size of block
      if i == nl-1 # If it reachs border
        idl = [l*i+1:ltot]; 
      end
      if j == nc-1
        idc = [c*j+1:ctot];
      end
      lt = size(idl,2); # Total lines of block (i,j)
      ct = size(idc,2); # Total columns of block (i,j)
      #########################################
      
      # Compression - Decompression
      X = reshape(Yini(idl, idc,:), lt*ct, trois); # Reshaping (m, n, 3) -> (m*n,3)
      m = mean(X); e = std(X);
      for ie = 1:3
        if e(1,ie) == 0
          e(1, ie) = 1;
        endif
      endfor
      X_centralised = (X - m) ./ e;  # Centralising X, in order to use codeur_ACP
      [P, E, Ip] = codeur_ACP(X_centralised, p);

      # Decoding
      X = decodeur_ACP(P, E).*e + m;
      
      # Compute Information
      Ips(it,1) = sum(Ip(1:p,:)); 
      it = it + 1;
      
      # Rematch Yb with Y
      Yb = reshape(X, lt,ct,3);
      Yfin(idl,idc,:) = Yb;
      
      # Blocs totals envoyes
      blocs_envoyes = blocs_envoyes + numel(P);
    end
    
  end

  figure(p)
  image(uint8(Yfin))
  bits_envoyes = blocs_envoyes/numel(Yini);
  str = sprintf("p = %d ; mean(I) = %.1f ; bits envoyé = %.2f",p,mean(Ips),bits_envoyes);
  title(str);
  
  
  axis equal;
end