# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + "/../lib/ingreedy")

RSpec::Matchers.define :parse_the_unit do |unit|
  match do |ingreedy_output|
    ingreedy_output.unit == unit
  end
  failure_message_for_should do |ingreedy_output|
    "expected to parse the unit #{unit} from the query '#{ingreedy_output.query}' " +
    "got '#{ingreedy_output.unit}' instead"
  end
end
RSpec::Matchers.define :parse_the_amount do |amount|
  match do |ingreedy_output|
    ingreedy_output.amount == amount
  end
  failure_message_for_should do |ingreedy_output|
    "expected to parse the amount #{amount} from the query '#{ingreedy_output.query}.' " +
    "got '#{ingreedy_output.amount}' instead"
  end
end
RSpec::Matchers.define :parse_the_prep_method do |prep_method|
  match do |ingreedy_output|
    ingreedy_output.prep_method == prep_method
  end
  failure_message_for_should do |ingreedy_output|
    "expected to parse the prep method #{prep_method} from the query '#{ingreedy_output.query}' " +
    "got '#{ingreedy_output.prep_method}' instead"
  end
end

describe "amount formats" do
  before(:all) do
    @expected_amounts = {}
    @expected_amounts["1 cup flour"] = 1.0
    @expected_amounts["1 1/2 cups flour"] = 1.5
    @expected_amounts["1.0 cup flour"] = 1.0
    @expected_amounts["1.5 cups flour"] = 1.5
    @expected_amounts["1-1/2 cups flour"] = 1.5
    @expected_amounts["1 2/3 cups flour"] = 1 + 2/3.to_f
    @expected_amounts["1 (28 ounce) can crushed tomatoes"] = 28
    @expected_amounts["2 (28 ounce) can crushed tomatoes"] = 56
    @expected_amounts["4 (403 ml) can crushed tomatoes"] = 1612.0
    @expected_amounts["1/2 cups flour"] = 0.5
    @expected_amounts[".25 cups flour"] = 0.25
    @expected_amounts["12oz tequila"] = 12
    @expected_amounts['½ cup coconut flour'] = 0.5
    @expected_amounts['1½ cup coconut flour'] = 1.5
  end

  it "should parse the correct amount as a float" do
    @expected_amounts.each do |query, expected|
      Ingreedy.parse(query).should parse_the_amount(expected)
    end
  end
end

describe "prep_method" do
  before(:all) do
    @expected_prep_methods = {
      "diced tomatoes" => :dice,
      "dice tomatoes" => :dice,
      "slice tomatoes" => :slice,
      "sliced tomatoes" => :slice,
      "chopped tomatoes" => :chop,
      "chop tomatoes" => :chop,
      "dash of pepper" => :dash,
      "pinch of salt" => :pinch,
      "minced garlic" => :mince,
      "cubed cheese" => :cube,
      "cube cheese" => :cube,
      "shredded cheese" => :shred,
      "shred cheese" => :shred,
      "drizzle of olive oil" => :drizzle,
      "peeled carrots" => :peel,
      "grated nutmeg" => :grated,
      "grate fresh ginger" => :grated
    }
  end
  
  it "should parse the prep method from the ingredient" do
    @expected_prep_methods.each do |query, expected|
      Ingreedy.parse(query).prep_method.should == expected
    end
  end
end

describe "english units" do
  context "abbreviated" do
    before(:all) do
      @expected_units = {}
      @expected_units["1 c flour"] = :cup
      @expected_units["1 c. flour"] = :cup
      @expected_units["1 fl oz flour"] = :fluid_ounce
      @expected_units["1 fl. oz. flour"] = :fluid_ounce
      @expected_units["1 (28 fl oz) can crushed tomatoes"] = :fluid_ounce
      @expected_units["2 gal flour"] = :gallon
      @expected_units["2 gal. flour"] = :gallon
      @expected_units["1 ounce flour"] = :ounce
      @expected_units["2 ounces flour"] = :ounce
      @expected_units["1 oz flour"] = :ounce
      @expected_units["1 oz. flour"] = :ounce
      @expected_units["2 pt flour"] = :pint
      @expected_units["2 pt. flour"] = :pint
      @expected_units["1 lb flour"] = :pound
      @expected_units["1 lb. flour"] = :pound
      @expected_units["1 lbs flour"] = :pound
      @expected_units["1 lbs. flour"] = :pound
      @expected_units["1 pound flour"] = :pound
      @expected_units["2 pounds flour"] = :pound
      @expected_units["2 qt flour"] = :quart
      @expected_units["2 qt. flour"] = :quart
      @expected_units["2 qts flour"] = :quart
      @expected_units["2 qts. flour"] = :quart
      @expected_units["2 tbsp flour"] = :tablespoon
      @expected_units["2 tbsp. flour"] = :tablespoon
      @expected_units["2 Tbs flour"] = :tablespoon
      @expected_units["2 Tbs. flour"] = :tablespoon
      @expected_units["2 T flour"] = :tablespoon
      @expected_units["2 T. flour"] = :tablespoon
      @expected_units["2 tsp flour"] = :teaspoon
      @expected_units["2 tsp. flour"] = :teaspoon
      @expected_units["2 t flour"] = :teaspoon
      @expected_units["2 t. flour"] = :teaspoon
      # zobar uncovered this bug:
      @expected_units["12oz tequila"] = :ounce
      @expected_units["2 TSP flour"] = :teaspoon
      @expected_units["1 LB flour"] = :pound
    end
    it "should parse the units correctly" do
      @expected_units.each do |query, expected|
        # Ingreedy.parse(query).unit.should == expected
        Ingreedy.parse(query).should parse_the_unit(expected)
      end
    end
  end
  context "long form" do
    before(:all) do
      @expected_units = {}
      @expected_units["1 cup flour"] = :cup
      @expected_units["2 cups flour"] = :cup
      @expected_units["1 fluid ounce flour"] = :fluid_ounce
      @expected_units["2 fluid ounces flour"] = :fluid_ounce
      @expected_units["2 gallon flour"] = :gallon
      @expected_units["2 gallons flour"] = :gallon
      @expected_units["2 pint flour"] = :pint
      @expected_units["2 pints flour"] = :pint
      @expected_units["1 quart flour"] = :quart
      @expected_units["2 quarts flour"] = :quart
      @expected_units["2 tablespoon flour"] = :tablespoon
      @expected_units["2 tablespoons flour"] = :tablespoon
      @expected_units["2 teaspoon flour"] = :teaspoon
      @expected_units["2 teaspoons flour"] = :teaspoon
    end
    it "should parse the units correctly" do
      @expected_units.each do |query, expected|
        Ingreedy.parse(query).unit.should == expected
      end
    end
  end
end

describe "metric units" do
  context "abbreviated" do
    before(:all) do
      @expected_units = {}
      @expected_units["1 g flour"] = :gram
      @expected_units["1 g. flour"] = :gram
      @expected_units["1 gr flour"] = :gram
      @expected_units["1 gr. flour"] = :gram
      @expected_units["1 kg flour"] = :kilogram
      @expected_units["1 kg. flour"] = :kilogram
      @expected_units["1 l water"] = :liter
      @expected_units["1 l. water"] = :liter
      @expected_units["1 mg water"] = :milligram
      @expected_units["1 mg. water"] = :milligram
      @expected_units["1 ml water"] = :milliliter
      @expected_units["1 ml. water"] = :milliliter
      @expected_units["1 (403 mL) can water"] = :milliliter
    end
    it "should parse the units correctly" do
      @expected_units.each do |query, expected|
        Ingreedy.parse(query).unit.should == expected
      end
    end
  end
  context "long form" do
    before(:all) do
      @expected_units = {}
      @expected_units["1 gram flour"] = :gram
      @expected_units["2 grams flour"] = :gram
      @expected_units["1 kilogram flour"] = :kilogram
      @expected_units["2 kilograms flour"] = :kilogram
      @expected_units["1 liter water"] = :liter
      @expected_units["2 liters water"] = :liter
      @expected_units["1 milligram water"] = :milligram
      @expected_units["2 milligrams water"] = :milligram
      @expected_units["1 milliliter water"] = :milliliter
      @expected_units["2 milliliters water"] = :milliliter
    end
    it "should parse the units correctly" do
      @expected_units.each do |query, expected|
        Ingreedy.parse(query).unit.should == expected
      end
    end
  end
end

describe "without units" do
  before(:all) { @ingreedy = Ingreedy.parse "3 eggs, lightly beaten" }

  it "should have an amount of 3" do
    @ingreedy.amount.should == 3
  end

  it "should have a nil unit" do
    @ingreedy.unit.should be_nil
  end

  it "should have the correct ingredient" do
    @ingreedy.ingredient.should == "eggs, lightly beaten"
  end
end

describe "ingredient formatting" do
  it "should not have any preceding or trailing whitespace" do
    Ingreedy.parse("1 cup flour ").ingredient.should == "flour"
  end
end
