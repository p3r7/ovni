

--- Like tabutil.key except allows non-numeric keys
function find_in_table(search_v, t)
  local index={}
  for k, v in pairs(t) do
    if v == search_v then
      return k
    end
  end
end
