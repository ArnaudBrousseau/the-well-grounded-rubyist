module P
end

class Object
  prepend P
end

module M
end

class C
end

c = C.new

class << c
  include M
  prepend P
end

p c.singleton_class.ancestors
