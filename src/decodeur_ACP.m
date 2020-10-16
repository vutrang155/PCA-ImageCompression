# Decoding image X 
function X = decodeur_ACP(P, E)
  % Decoding image X with P principal matrix and E rotational matrix
  % 
  %   X = decodeur_ACP(P, E) decodes X using P the compressed data and E 
  %   rotational matrix. it uses the transformation : X = P*E'
  X = P*E.';
endfunction