function newvec = insert(oldvec, value, ind)
    
    newvec = {oldvec{1:ind-1} value oldvec{ind:end}};
end