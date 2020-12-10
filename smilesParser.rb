require_relative "constants"
require_relative "molecule"
require_relative "atom"
require_relative "parsingError"
require "strscan"

class SmilesParser
    def initialize(str)
        @scanner = StringScanner.new str.chomp
    end

    def checkSymb(symbol)
        if !Constants::ATOMIC_SYMBOLS.keys.include? symbol
            raise ParsingError.new "The atomic symbol #{symbol} is not yet implemented", "atomSym"
        end
        Constants::ATOMIC_SYMBOLS[symbol]
    end

    def parseMolecule
        molecule = Molecule.new
        prevAtom = nil
        curToken = readNextSymb
        if curToken == nil 
            return molecule
        end
        if curToken["type"] != "atom"
            raise ParsingError.new "SMILES notation must begin with atomic symbol"
        end
        while curToken and curToken["type"] != "break" do
            if curToken["type"] == "atom" then
                atom = Atom.new checkSymb curToken["val"]
                molecule.addAtom! atom
                molecule.addBond! prevAtom, atom  unless prevAtom == nil
                prevAtom = atom
            elsif curToken["type"] == "branch" then
                tempMol = parseMolecule
                molecule.addMol! tempMol, prevAtom
            end
            curToken = readNextSymb
        end
        molecule
    end

    def readNextSymb
        if @scanner.eos? 
            return nil
        end
        ch = @scanner.peek 1
        if isAtomic? ch
            return readAtomSymb
        end
        if isBranch? ch
            return readBranchSymb
        end
        if isBreak? ch
            return readBreakSymb
        end
        raise ParsingError.new "Do not understand char #{ch}", "char"
    end

    def isAtomic?(ch)
        ch.ord >= 'A'.ord and ch.ord <= 'Z'.ord
    end

    def isBranch?(ch)
        ch == "("
    end

    def isBreak?(ch)
        ch == ")"
    end

    def readAtomSymb
        atomicSymbol = @scanner.getch
        ch = @scanner.peek 1
        if ch != nil and ch != "" then
            if ch.ord >= 'a'.ord and ch.ord <= 'z'.ord
                atomicSymbol += ch
                @scanner.getch
            end
        end
        return {"type" => "atom", "val" => atomicSymbol}
    end

    def readBranchSymb
        @scanner.getch
        return {"type" => "branch", "val" => ""} # Val could hold bond symbol, but bond symbols are not supported in this interpreter
    end

    def readBreakSymb
        @scanner.getch
        return {"type" => "break", "val" => ")"}
    end

    def scanner
        @scanner
    end
end