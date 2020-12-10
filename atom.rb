=begin
    Implements a simple atom defined by it's atomic number.
    Keeps track of bonds it has to other atoms.
=end

require_relative "constants"

class Atom
    def initialize(atomic_number = 6)
        @number = atomic_number
    end

    def number
        @number
    end

    def getAtomicSymbol
        symbol = Constants::ATOMIC_SYMBOLS.key(@number)
        if !symbol
            raise KeyError, "No symbol found for atomic number #{@number} in ATOMIC_SYMBOLS table"
        end
        symbol
    end
end
