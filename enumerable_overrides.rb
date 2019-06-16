overrides = {}

enum_classes = ObjectSpace.each_object(Class).select do |c|
  c.ancestors.include?(Enumerable) && c.class
end

enum_classes.each do |c|
  override_for_c = c.instance_methods(false) & Enumerable.instance_methods(false)
  overrides[c] = override_for_c unless override_for_c.empty?
end

overrides.each do |c, methods|
  puts "Class #{c} overrides #{methods.sort.join(", ")}"
end
