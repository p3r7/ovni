


--- Linear interpolation between a and b
function lerp(a,b,t)
  return a+(b-a)*t
end

--- Finds the t value that would return v in a lerp between a and b
function invlerp(a,b,v)
  return (v-a)/(b-a)
end
