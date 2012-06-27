# This class provides generic handling for obtaining parts of a facter hash
class Facter::Util::Query
  def initialize(query_string)
    @query_string = query_string
    @decomposed_query = decompose_query(query_string)
  end

  # Return the current query string as text only
  def query_string
    @query_string
  end

  # Return the current decomposed query as an array
  def decomposed_query
    @decomposed_query
  end

  # Return a decomposed query string whereby each descending element is
  # returned as an element within an array
  def decompose_query(query_string)
    m = query_string.match(/^(\w+)(\[?.*)/)
    first_part = m[1]
    remainder  = m[2]

    rparts = remainder.split(/(?:\[|\]\[|\])/)
    rparts.shift if rparts[0] == ''

    rparts.collect! do |r|
      # Remove leading and trailing quotes
      if m = r.match(/^["'](.*?)["']$/)
        m[1]
      elsif r.match(/^-?\d+$/)
        Integer(r)
      elsif r.match(/^\*$/)
        '*'
      else
        raise "Something wrong with the token #{r}"
      end
    end

    [first_part, *rparts]
  end

  def is_flat?
    if @decomposed_query.length == 1
      true
    else
      false
    end
  end

  # Search facts
  def search_facts(facts = Facter.to_hash, query = @decomposed_query)
    traverse_hash(facts, query)
  end

  # Traverse a hash using a decomposed query string
  def traverse_hash(hash, query)
    query.inject(hash) do |cur, d|
      case d
      when String
        if cur.is_a? Hash
          elem = cur.fetch(d, :noelem)
          if elem != :noelem
            elem
          else
            raise "Element #{d} doesn't exist"
          end
        else
          raise "You can only use a string index when type is a hash"
        end
      when Fixnum
        if cur.is_a? Hash or cur.is_a? Array
          elem = cur.fetch(d, :noelem)
          if elem != :noelem
            elem
          else
            raise "Element #{d} doesn't exist"
          end
        else
          raise "Only use numeric index when type is an array or hash"
        end
      else
        raise "Token element #{d} is invalid"
      end
    end
  end

end
