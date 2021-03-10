 function normalized = normalize_var(array, x, y)

     % Then scale to [x,y]:
     if(max(array) == min(array))
         normalized = array;
     else
         range_norm = y - x;
         array_norm = (array - min(array))./(max(array)-min(array));
         normalized = range_norm.*array_norm + x;
     end
     normalized(isnan(normalized)) = 0;