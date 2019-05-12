class Person
  PEOPLE = []
  attr_reader :name, :hobbies, :friends
  def initialize(name)
    @name = name
    @hobbies = []
    @friends = []
    PEOPLE << self
  end

  def has_hobby(hobby)
    @hobbies << hobby
  end

  def has_friend(friend)
    @friends << friend
  end

  def self.method_missing(m, *args)
    method = m.to_s
    if method.start_with?('all_with')
      attr = method[9..-1]
      if self.public_method_defined?(attr)
        PEOPLE.find_all do |person|
          person.send(attr).include?(args[0])
        end
      else
        raise ArgumentError, "Cannot find #{attr}"
      end
    else
      super
    end
  end
end

a = Person.new('Arnaud B')
m = Person.new('Ryan N')
m.has_friend(a)
a.has_hobby('surfing')
m.has_hobby('interior design ')

Person.all_with_hobbies('surfing')
