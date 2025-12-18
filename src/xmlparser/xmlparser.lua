local xml = {}

function xml:parse(str)
  local function trim(s)
    return string.gsub(string.gsub(s,"%s+$",""),"^%s+","")
  end
  str = trim(str)
  local chr, t, la
  local n = 0
  local inTag = false
  local foundRoot = false
  local function nextChr()
    n = n + 1
    chr = string.sub(str, n, n)
  end
  nextChr()
  local function expectNextChr(c)
    nextChr()
    if chr ~= c then
      error("invalid character '"..chr.."', expected '"..c.."'")
    end
  end
  local function readEntity()
    nextChr()
    if chr == "l" then
      expectNextChr("t")
      expectNextChr(";")
      chr = "<"
    elseif chr == "g" then
      expectNextChr("t")
      expectNextChr(";")
      chr = ">"
    elseif chr == "a" then
      nextChr()
      if chr == "m" then
        expectNextChr("p")
        expectNextChr(";")
        chr = "&"
      elseif chr == "p" then
        expectNextChr("o")
        expectNextChr("s")
        expectNextChr(";")
        chr = "'"
      else
        error("invalid entity")
      end
    elseif chr == "q" then
        expectNextChr("u")
        expectNextChr("o")
        expectNextChr("t")
        expectNextChr(";")
        chr = '"'
    else
      error("invalid entity")
    end
  end
  local function isLetter(c)
    return string.match(c,"[a-zA-Z]")
  end
  local function readString(t)
    t.kind = "string"
    t.val = ""
    nextChr()
    while chr ~= '"' and chr ~= "" do
      t.val = t.val .. chr
      nextChr()
    end
    nextChr()
  end
  local function readName(t)
    t.kind = "name"
    t.val = ""
    while isLetter(chr) and chr ~= "" do
      t.val = t.val .. chr
      nextChr()
    end
  end
  local function nextLa()
    la = {}
    if chr == "" then
      la.kind = "eof"
      return
    end
    if inTag or not foundRoot then
      while string.match(chr, "%s") do
        nextChr()
      end
    end
    if inTag then
      if chr == "=" then
        la.kind = "assign"
        nextChr()
      elseif chr == '"' then
        readString(la)
      elseif chr == "/" then
        la.kind = "rangleslash"
        expectNextChr(">")
        nextChr()
        inTag = false
      elseif chr == "?" then
        la.kind = "rpro"
        expectNextChr(">")
        nextChr()
        inTag = false
      elseif chr == ">" then
        la.kind = "rangle"
        nextChr()
        inTag = false
      elseif isLetter(chr) then
        readName(la)
      else
        error("invalid symbol "..chr)
      end
    else
      if chr == "<" then
        nextChr()
        inTag = true
        if chr == "?" then
          nextChr()
          la.kind = "lpro"
        elseif chr == "/" then
          nextChr()
          la.kind = "langleslash"
        else
          foundRoot = true
          la.kind = "langle"
        end
      else
        nextChr()
        la.kind = "text"
        la.val = ""
        while chr ~= "<" do
          if chr == "&" then
            readEntity()
          end
          la.val = la.val .. chr
          nextChr()
        end
        la.val = trim(la.val)
        if la.val == "" then
          nextLa()
        end
      end
    end
  end
  local function next()
    t = la
    nextLa()
  end
  local function expect(kind)
    next()
    if t.kind ~= kind then
      error("unexpected token '"..t.kind.."', expected '"..kind.."'")
    end
  end
  local rootNode
  local function TagContent()
    local attributes = {}
    local name = la.val
    next()
    while la.kind ~= "rangle" and la.kind ~= "rpro" do
      expect("name")
      local key = t.val
      expect("assign")
      expect("string")
      local value = t.val
      if attributes[key] then
        error("duplicate attribute '"..key.."'")
      end
      attributes[key] = value
    end
    return {name=name,attributes=attributes}
  end
  local function Tag()
    local ret
    if la.kind == "langle" then
      expect("langle")
      ret = TagContent()
      if la.kind == "rangleslash" then
        expect("rangleslash")
      else
        expect("rangle")
      end
    else
      expect("langleslash")
      ret = TagContent()
      expect("rangle")
    end
    return ret
  end
  local function Node(parent)
    if la.kind == "text" then
      next()
      if t.val ~= "" then
        table.insert(
          parent.children,
          {type="text",value=t.val,children={},attributes={}}
        )
      end
    else
      local this = {children={}}
      if parent then
        table.insert(parent.children, this)
      else
        rootNode = this
      end
      local opening = Tag()
      this.name = opening.name
      this.attributes = opening.attributes
      while la.kind ~= "langleslash" and la.kind ~= "eof" do
        Node(this)
      end
      local closing = Tag()
      if closing.name ~= opening.name then
        error("expected closing tag of '"..opening.name.."', got '"..closing.name.."'")
      end
    end
  end
  local prolog
  local function Prolog()
    expect("lpro")
    prolog = TagContent().attributes
    expect("rpro")
  end
  local function XML()
    next()
    if la.kind == "lpro" then
      Prolog()
    end
    Node()
    expect("eof")
  end
  XML()
  return {root=rootNode,prolog=prolog}
end

return xml
