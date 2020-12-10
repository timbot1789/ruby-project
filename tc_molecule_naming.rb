require_relative "molecule"
require_relative "smilesParser"
require "test/unit"

# These test cases assume the SMILES parser is working correctly
class TestMoleculeNaming < Test::Unit::TestCase

    def test_get_incomplete_name_simple
        parser = SmilesParser.new "C"
        molecule = parser.parseMolecule
        assert_equal("meth", molecule.getIncompleteName)
        parser = SmilesParser.new "CC"
        molecule = parser.parseMolecule
        assert_equal("eth", molecule.getIncompleteName)
        parser = SmilesParser.new "CCC"
        molecule = parser.parseMolecule
        assert_equal("prop", molecule.getIncompleteName)
        parser = SmilesParser.new "CCCC"
        molecule = parser.parseMolecule
        assert_equal("but", molecule.getIncompleteName)
    end

    def test_get_subst_name_simple
        parser = SmilesParser.new "C"
        molecule = parser.parseMolecule
        assert_equal("methyl", molecule.getSubstName)
        parser = SmilesParser.new "CC"
        molecule = parser.parseMolecule
        assert_equal("ethyl", molecule.getSubstName)
        parser = SmilesParser.new "CCC"
        molecule = parser.parseMolecule
        assert_equal("propyl", molecule.getSubstName)
        parser = SmilesParser.new "CCCC"
        molecule = parser.parseMolecule
        assert_equal("butyl", molecule.getSubstName)
    end

    def test_get_subst_name_branched
        parser = SmilesParser.new "C(C)C"
        molecule = parser.parseMolecule
        name = molecule.getSubstName
        assert_equal("(1-methylethyl)", name)
    end

    def test_get_subst_name_complex
        parser = SmilesParser.new "C(CC)C(C)C"
        molecule = parser.parseMolecule
        name = molecule.getSubstName
        assert_equal("(1-ethyl-2-methylpropyl)", name)
    end

    def test_get_prefix_simple
        parser = SmilesParser.new "CC(C)C"
        molecule = parser.parseMolecule
        assert_equal("2-methyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_direction
        parser = SmilesParser.new "CCCC(C)C"
        molecule = parser.parseMolecule
        assert_equal("2-methyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_multi
        parser = SmilesParser.new "CC(C)C(C)C"
        molecule = parser.parseMolecule
        assert_equal("2,3-dimethyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_same_mol
        parser = SmilesParser.new "CCC(C)(C)CC"
        molecule = parser.parseMolecule
        assert_equal("3,3-dimethyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_ethyl
        parser = SmilesParser.new "CCC(CC)CCC"
        molecule = parser.parseMolecule
        assert_equal("3-ethyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_different
        parser = SmilesParser.new "CCCC(CC)C(C)CCCC"
        molecule = parser.parseMolecule
        assert_equal("4-ethyl-5-methyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_alphabetized
        parser = SmilesParser.new "CCCC(C)C(CC)CCCC"
        molecule = parser.parseMolecule
        assert_equal("5-ethyl-4-methyl", molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_branched
        parser = SmilesParser.new "CCC(C(C)C)CCC"
        molecule = parser.parseMolecule
        assert_equal("3-ethyl-2-methyl",molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_branched_2
        parser = SmilesParser.new "CCCCC(C(C)CC)CCCC"
        molecule = parser.parseMolecule
        assert_equal("5-(1-methylpropyl)",molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_branched_3
        parser = SmilesParser.new "CCCCC(C(C)(C)C)CCCC"
        molecule = parser.parseMolecule
        assert_equal("5-(1,1-dimethylethyl)",molecule.getPrefix(molecule.findParentString))
    end

    def test_get_prefix_branched_4
        parser = SmilesParser.new "CCCCC(CC(C)C)CCCC"
        molecule = parser.parseMolecule
        assert_equal("5-(2-methylpropyl)",molecule.getPrefix(molecule.findParentString))
    end

    def test_simple_naming
        parser = SmilesParser.new "C"
        molecule = parser.parseMolecule
        assert_equal("methane", molecule.calcIUPACname)
        parser = SmilesParser.new "CC"
        molecule = parser.parseMolecule
        assert_equal("ethane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCC"
        molecule = parser.parseMolecule
        assert_equal("propane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCC"
        molecule = parser.parseMolecule
        assert_equal("butane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCC"
        molecule = parser.parseMolecule
        assert_equal("pentane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCCC"
        molecule = parser.parseMolecule
        assert_equal("hexane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCCCC"
        molecule = parser.parseMolecule
        assert_equal("heptane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCCCCC"
        molecule = parser.parseMolecule
        assert_equal("octane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCCCCCC"
        molecule = parser.parseMolecule
        assert_equal("nonane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCCCCCCC"
        molecule = parser.parseMolecule
        assert_equal("decane", molecule.calcIUPACname)
    end

    def test_full_names
        parser = SmilesParser.new "CC(C)CCC"
        molecule = parser.parseMolecule
        assert_equal("2-methylpentane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCC(C)C"
        molecule = parser.parseMolecule
        assert_equal("2-methylpentane", molecule.calcIUPACname)
        parser = SmilesParser.new "CC(C)C(C)CCC"
        molecule = parser.parseMolecule
        assert_equal("2,3-dimethylhexane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCC(C)C(C)C"
        molecule = parser.parseMolecule
        assert_equal("2,3-dimethylhexane", molecule.calcIUPACname)
        parser = SmilesParser.new "CC(C)C(C)(C)CCC"
        molecule = parser.parseMolecule
        assert_equal("2,3,3-trimethylhexane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCC(C)C(CC)CCC"
        molecule = parser.parseMolecule
        assert_equal("4-ethyl-3-methylheptane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCC(C)(C)C(CC)CCC"
        molecule = parser.parseMolecule
        assert_equal("4-ethyl-3,3-dimethylheptane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCC(C)C(CC)(C)CCC"
        molecule = parser.parseMolecule
        assert_equal("4-ethyl-3,4-dimethylheptane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCC(CCC)C(CC)CCC"
        molecule = parser.parseMolecule
        assert_equal("4-ethyl-5-propyloctane", molecule.calcIUPACname)
        parser = SmilesParser.new "CC(C)(C)CC(CC)CC"
        molecule = parser.parseMolecule
        assert_equal("4-ethyl-2,2-dimethylhexane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCC(CCC)CCC(C)C"
        molecule = parser.parseMolecule
        assert_equal("5-ethyl-2-methyloctane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCC(C(C)C)CCC"
        molecule = parser.parseMolecule
        assert_equal("3-ethyl-2-methylhexane", molecule.calcIUPACname)
    end

    def test_full_name_complex
        parser = SmilesParser.new "CCCCC(C(CC)C(C)CC)CCCCC"
        molecule = parser.parseMolecule
        assert_equal("5-butyl-4-ethyl-3-methyldecane", molecule.calcIUPACname)
    end

    def test_branched_substituents
        parser = SmilesParser.new "CCCC(C(C)C)CCCC"
        molecule = parser.parseMolecule
        assert_equal("4-(1-methylethyl)octane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCC(C(C)CC)CCCC"
        molecule = parser.parseMolecule
        assert_equal("5-(1-methylpropyl)nonane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCC(C(C)(C)C)CCC"
        molecule = parser.parseMolecule
        assert_equal("4-(1,1-dimethylethyl)heptane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCC(CC(C)C)CCCC"
        molecule = parser.parseMolecule
        assert_equal("5-(2-methylpropyl)nonane", molecule.calcIUPACname)
        parser = SmilesParser.new "CCCCC(C(CC)C(C)C)CCCCC"
        molecule = parser.parseMolecule
        assert_equal("5-(1-ethyl-2-methylpropyl)decane", molecule.calcIUPACname)
    end

end