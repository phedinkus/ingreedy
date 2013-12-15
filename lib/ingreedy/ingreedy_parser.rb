# encoding: UTF-8
class IngreedyParser
  attr_reader :amount, :unit, :ingredient, :query, :prep_method

  UTF_FRACTIONS = {
      "\u00BC" => 1.0 / 4.0,
      "\u00BD" => 1.0 / 2.0,
      "\u00BE" => 3.0 / 4.0,
      "\u2150" => 1.0 / 7.0,
      "\u2151" => 1.0 / 9.0,
      "\u2152" => 1.0 /10.0,
      "\u2153" => 1.0 / 3.0,
      "\u2154" => 2.0 / 3.0,
      "\u2155" => 1.0 / 5.0,
      "\u2156" => 2.0 / 5.0,
      "\u2157" => 3.0 / 5.0,
      "\u2158" => 4.0 / 5.0,
      "\u2159" => 1.0 / 6.0,
      "\u215A" => 5.0 / 6.0,
      "\u215B" => 1.0 / 8.0,
      "\u215C" => 3.0 / 8.0,
      "\u215D" => 5.0 / 8.0,
      "\u215E" => 7.0 / 8.0,
      "\u2189" => 0.0 / 3.0,
  }

  PREP_METHODS = {
    slice:   ["slice", "slices", "sliced"],
    dice:    ["dice", "diced"],
    chop:    ["chop", "chopped"],
    dash:    ["dash"],
    pinch:   ["pinch", "pinch of"],
    mince:   ["mince", "minced"],
    cube:    ["cubed", "cube"],
    shred:   ["shred", "shredded"],
    drizzle: ["drizzle", "drizzle of"],
    peel:    ["peel", "peeled"],
    grated:  ["grate", "grated"]
  }

  LOOKUP_REGEX = Regexp.union(UTF_FRACTIONS.keys)

  INGREEDY_REGEX = %r{
    (?<amount> .?\d+(\.\d+)? ) {0}
    (?<fraction> \d\/\d ) {0}

    (?<container_amount> \d+(\.\d+)?) {0}
    (?<container_unit> .+) {0}
    (?<container_size> \(\g<container_amount>\s\g<container_unit>\)) {0}
    (?<unit_and_ingredient> .+ ) {0}

    (\g<fraction>\s)?(\g<amount>\s?)?(\g<fraction>\s)?(\g<container_size>\s)?\g<unit_and_ingredient>
  }x

  def initialize(query)
    @query = query
  end

  def parse
    normalize_query

    results = INGREEDY_REGEX.match(@query)

    @ingredient_string  = results[:unit_and_ingredient]
    @container_amount   = results[:container_amount]
    @container_unit     = results[:container_unit]

    parse_amount(results[:amount], results[:fraction])
    parse_unit_and_ingredient
  end

  private

  def normalize_query
    sub_utf_chars
    sub_fraction_dash
  end

  def sub_utf_chars
    sub_utf_whitespace
    sub_utf_fractions
  end

  def sub_utf_whitespace
    @query = @query.gsub(/\u00a0/, ' ').strip
  end

  def sub_utf_fractions
    @query = @query.sub(LOOKUP_REGEX) { |m| UTF_FRACTIONS[m].to_s[1..-1] }
  end

  def sub_fraction_dash 
    @query = @query.sub(%r{\d?-\d\/}) { |m| m.sub("-", " ") }
  end

  def normalize_fraction(fraction_string)
    if fraction_string
      numbers = fraction_string.split("\/")
      numerator = numbers[0].to_f
      denominator = numbers[1].to_f
      numerator / denominator
    else
      0
    end
  end

  def parse_amount(amount_string, fraction_string)
    fraction = normalize_fraction(fraction_string)

    @amount = amount_string.to_f + fraction
    @amount *= @container_amount.to_f if @container_amount
  end

  def set_unit_variations(unit, variations)
    variations.each do |abbrev|
      @unit_map[abbrev] = unit
    end
  end

  # todo: add "can"
  def create_unit_map
    @unit_map = {}
    # english units
    set_unit_variations :cup, ["c.", "c", "cup", "cups"]
    set_unit_variations :fluid_ounce, ["fl. oz.", "fl oz", "fluid ounce", "fluid ounces"]
    set_unit_variations :gallon, ["gal", "gal.", "gallon", "gallons"]
    set_unit_variations :ounce, ["oz", "oz.", "ounce", "ounces"]
    set_unit_variations :pint, ["pt", "pt.", "pint", "pints"]
    set_unit_variations :pound, ["lb", "lb.", 'lbs', 'lbs.', "pound", "pounds"]
    set_unit_variations :quart, ["qt", "qt.", "qts", "qts.", "quart", "quarts"]
    set_unit_variations :tablespoon, ["tbsp.", "tbsp", "T", "T.", "tablespoon", "tablespoons", "Tbs.", "tbs.", "tbs"]
    set_unit_variations :teaspoon, ["tsp.", "tsp", "t", "t.", "teaspoon", "teaspoons"]
    # metric units
    set_unit_variations :gram, ["g", "g.", "gr", "gr.", "gram", "grams"]
    set_unit_variations :kilogram, ["kg", "kg.", "kilogram", "kilograms"]
    set_unit_variations :liter, ["l", "l.", "liter", "liters"]
    set_unit_variations :milligram, ["mg", "mg.", "milligram", "milligrams"]
    set_unit_variations :milliliter, ["ml", "ml.", "mL", "milliliter", "milliliters"]
    # set_unit_variations :can, ["can"]
  end

  def parse_unit
    create_unit_map if @unit_map.nil?

    @unit_map.each do |abbrev, unit|
      if @ingredient_string.start_with?(abbrev + " ")
        # if a unit is found, remove it from the ingredient string
        @ingredient_string.sub! abbrev, ""
        @unit = unit
      end
    end

    # if no unit yet, try it again downcased
    if @unit.nil?
      @ingredient_string.downcase!
      @unit_map.each do |abbrev, unit|
        if @ingredient_string.start_with?(abbrev + " ")
          # if a unit is found, remove it from the ingredient string
          @ingredient_string.sub! abbrev, ""
          @unit = unit
        end
      end
    end

    # if we still don't have a unit, check to see if we have a container unit
    if @unit.nil? and @container_unit
      @unit_map.each do |abbrev, unit|
        @unit = unit if abbrev == @container_unit
      end
    end
  end

  def parse_prep_method
    PREP_METHODS.each do |key, prep_methods|
      if @ingredient_string.match(Regexp.union(prep_methods)) != nil
        @prep_method = key
        break
      end
    end
  end

  def parse_unit_and_ingredient
    parse_unit
    # clean up ingredient string
    parse_prep_method
    @ingredient = @ingredient_string.lstrip.rstrip
  end
end
