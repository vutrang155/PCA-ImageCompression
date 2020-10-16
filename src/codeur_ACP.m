# Encoding image X
function [P, E, Ip] = codeur_ACP(X, p)
  % Encoding image X with p the number of principal variables
  % 
  %   [P, E, Ip] = codeur_ACP(X,p) returns P matrix of principal variables (p columns), E 
  %   rotational matrix and Ip the amount of information of each principal column.
  %   Attention: the argument X must be centralised
  %   It uses the transformation P = X*E
  
  n = size(X, 1);
  V = X.'*(X) ./ (n-1);
  [E, D] = eig(V); 

  # Sort 
  [~, idx] = sort(diag(D), 'descend');
  D = D(idx, idx);
  E = E(:, idx);
  Itot = sum(diag(D));
  
  # Calcul de l'information
  if Itot == 0  # Eviter la division par 0 
    Ip = diag(D)*100;
    Ip(1:1)=100;
  else
    Ip = diag(D)*100./Itot;
  endif
  
  #X = X.*e + m;
  P = X*E;
  Ip = Ip(1:p);
  P = P(:, 1:p);
  E = E(:, 1:p);
endfunction