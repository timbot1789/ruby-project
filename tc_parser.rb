require_relative "constants"
require_relative "molecule"
require_relative "atom"
require_relative "smilesParser"
require_relative "parsingError"
require "test/unit"

class TestParserBasic < Test::Unit::TestCase

    def test_init
        scanner = SmilesParser.new("A").scanner
        assert("A",scanner.getch)
    end


    def test_basic_smiles
        parser = SmilesParser.new("C")
        molecule = parser.parseMolecule
        atoms = molecule.atoms
        assert_equal(1, atoms.size)
        atoms.each {|key, val| assert_equal([], val)}
    end

    def test_smiles_empty_string
        parser = SmilesParser.new ""
        molecule = parser.parseMolecule
        assert_equal({}, molecule.atoms)
    end

    def test_smiles_bonds
        parser = SmilesParser.new("CC")
        molecule = parser.parseMolecule
        atoms = molecule.atoms
        assert_equal(2, atoms.size)
        atoms.each do | key, value |
            assert_not_equal(key, value[0])
            assert_equal(1, value.size)
            assert(atoms.key?(value[0]))
        end
    end

    def test_smiles_multibonds
        parser = SmilesParser.new("CCC")
        molecule = parser.parseMolecule
        atoms = molecule.atoms
        assert_equal(3, atoms.size)
        bonded = false
        atoms.each do | key, value |
            if value.size == 2
                bonded = true
                #check that other atoms are present in array
                assert(atoms.key?(value[0]))
                assert(atoms.key?(value[1]))

                # check atom is not bonded to itself
                assert_not_equal(key, value[0])
                assert_not_equal(key, value[1])

                # check other atoms are singly bonded
                assert_equal(1,atoms[value[0]].size)
                assert_equal(1,atoms[value[1]].size)

                # check other atoms are bound to center atom
                assert_equal(key, atoms[value[0]][0])
                assert_equal(key, atoms[value[1]][0])

            end
        end
        assert(bonded, "Atom with 2 bonds was not found")
    end

    def test_smiles_branching_basic
        parser = SmilesParser.new "C(C)"
        molecule = parser.parseMolecule
        atoms = molecule.atoms
        assert_equal(2, atoms.size)
        atoms.each do | key, value |
            assert_not_equal(key, value[0])
            assert_equal(1, value.size)
            assert(atoms.key?(value[0]))
        end
    end

    def test_smiles_branching
        parser = SmilesParser.new "CC(CC)CCC"
        molecule = parser.parseMolecule
        assert_equal(7, molecule.size)
        assert_equal(6, molecule.findParentString.size)
        parser = SmilesParser.new "CCC(CC)CC"
        molecule = parser.parseMolecule
        assert_equal(7, molecule.size)
        assert_equal(5, molecule.findParentString.size)
        parser = SmilesParser.new "CCCC(CC)C"
        molecule = parser.parseMolecule
        assert_equal(7, molecule.size)
        assert_equal(6, molecule.findParentString.size)
    end

    def test_smiles_branching_tolerant
        # This test case seems illegal according to this SMILES description that I used:
        #   https://archive.epa.gov/med/med_archive_03/web/html/smiles.html
        # But it's clear what's intended, and it is parsed by the ChemSpider interpreter at
        # http://www.chemspider.com
        # So we may as well support it.
        parser = SmilesParser.new "CC(CC"
        molecule = parser.parseMolecule
        atoms = molecule.atoms
        assert_equal(4, atoms.size)
    end

    def test_smiles_branching_complex
        parser = SmilesParser.new "CCC(CCC(CC)C(C))CC(CC)C"
        molecule = parser.parseMolecule
        atoms = molecule.atoms
        assert_equal(15, atoms.size)
        assert_equal(10, molecule.findParentString.size)
    end

    def test_smiles_branching_errors
        parser = SmilesParser.new "(C)"
        assert_raise(ParsingError){parser.parseMolecule}
        parser = SmilesParser.new "C((C))"
        assert_raise(ParsingError){parser.parseMolecule}
        parser = SmilesParser.new "C(A)"
        assert_raise(ParsingError){parser.parseMolecule}
        parser = SmilesParser.new "C=C"
        assert_raise(ParsingError){parser.parseMolecule}
    end
end
