#!/usr/bin/ruby

require_relative "molecule"
require_relative "smilesParser"
require_relative "parsingError"

if __FILE__ == $0
    print "Please input a SMILES notation string: "
    begin
        smiles = gets.chomp
        parser = SmilesParser.new smiles
        molecule = parser.parseMolecule
        puts molecule.calcIUPACname
    rescue ParsingError => e
        puts "ERROR: " + e.msg
    end
end