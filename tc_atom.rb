require_relative "atom"
require "test/unit"

class TestAtom < Test::Unit::TestCase

    def test_init
        assert_equal(6, Atom.new().number)
        assert_equal(7, Atom.new(7).number)
    end

    def test_raiseSymbolError
        assert_raise(KeyError){Atom.new(455).getAtomicSymbol}
    end

    def test_getsymbol
        assert_equal("C", Atom.new().getAtomicSymbol)
        assert_equal("C", Atom.new(6).getAtomicSymbol)
    end
end