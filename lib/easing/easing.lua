

-- -------------------------------------------------------------------------
-- linear

function linear(t)
  return t
end


-- -------------------------------------------------------------------------
-- quadratic

function easeinquad(t)
  return t*t
end

function easeoutquad(t)
  t = t-1
  return 1-t*t
end

function easeinoutquad(t)
  if(t<.5) then
    return t*t*2
  else
    t = t-1
    return 1-t*t*2
  end
end

function easeoutinquad(t)
  if t<.5 then
    t = t-.5
    return .5-t*t*2
  else
    t = t-.5
    return .5+t*t*2
  end
end


-- -------------------------------------------------------------------------
-- quartics

function easeinquart(t)
  return t*t*t*t
end

function easeoutquart(t)
  t = t-1
  return 1-t*t*t*t
end

function easeinoutquart(t)
  if t<.5 then
    return 8*t*t*t*t
  else
    t = t-1
    return (1-8*t*t*t*t)
  end
end

function easeoutinquart(t)
  if t<.5 then
    t = t-.5
    return .5-8*t*t*t*t
  else
    t = t-.5
    return .5+8*t*t*t*t
  end
end


-- -------------------------------------------------------------------------
-- overshooting functions

function easeinovershoot(t)
  return 2.7*t*t*t-1.7*t*t
end

function easeoutovershoot(t)
  t = t-1
  return 1+2.7*t*t*t+1.7*t*t
end

function easeinoutovershoot(t)
  if t<.5 then
    return (2.7*8*t*t*t-1.7*4*t*t)/2
  else
    t = t-1
    return 1+(2.7*8*t*t*t+1.7*4*t*t)/2
  end
end

function easeoutinovershoot(t)
  if t<.5 then
    t = t-.5
    return (2.7*8*t*t*t+1.7*4*t*t)/2+.5
  else
    t = t-.5
    return (2.7*8*t*t*t-1.7*4*t*t)/2+.5
  end
end


-- -------------------------------------------------------------------------
-- elastics

function easeinelastic(t)
  if(t==0) then
    return 0
  end
  return 2^(10*t-10)*cos(2*t-2)
end

function easeoutelastic(t)
  if(t==1) then
    return 1
  end
  return 1-2^(-10*t)*cos(2*t)
  end

function easeinoutelastic(t)
  if t<.5 then
    return 2^(10*2*t-10)*cos(2*2*t-2)/2
  else
    t = t-.5
    return 1-2^(-10*2*t)*cos(2*2*t)/2
  end
end

function easeoutinelastic(t)
  if t<.5 then
    return .5-2^(-10*2*t)*cos(2*2*t)/2
  else
    t = t-.5
    return 2^(10*2*t-10)*cos(2*2*t-2)/2+.5
  end
end


-- -------------------------------------------------------------------------
-- bouncing

function easeinbounce(t)
  t = 1-t
  local n1=7.5625
  local d1=2.75

  if (t<1/d1) then
    return 1-n1*t*t;
  elseif(t<2/d1) then
    t = t-1.5/d1
    return 1-n1*t*t-.75;
  elseif(t<2.5/d1) then
    t = t-2.25/d1
    return 1-n1*t*t-.9375;
  else
    t = t-2.625/d1
    return 1-n1*t*t-.984375;
  end
end

function easeoutbounce(t)
  local n1=7.5625
  local d1=2.75

  if (t<1/d1) then
    return n1*t*t;
  elseif(t<2/d1) then
    t = t-1.5/d1
    return n1*t*t+.75;
  elseif(t<2.5/d1) then
    t = t-2.25/d1
    return n1*t*t+.9375;
  else
    t = t-2.625/d1
    return n1*t*t+.984375;
  end
end
