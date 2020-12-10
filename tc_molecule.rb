require_relative "molecule"
require_relative "atom"
require "test/unit"

class TestMoleculeBasic < Test::Unit::TestCase

    def test_molecule_init
        assert_equal({}, Molecule.new().atoms)
    end

    def test_add_atom
        atom = Atom.new()
        molecule = Molecule.new()
        molecule.addAtom!(atom)
        assert_equal({atom => []}, molecule.atoms)
    end

    def test_add_bond
        atom1 = Atom.new()
        atom2 = Atom.new()
        molecule = Molecule.new()
        molecule.addBond!(atom1, atom2)
        assert_equal({atom1 => [atom2], atom2 => [atom1]}, molecule.atoms)
        atom3 = Atom.new()
        molecule.addBond!(atom2, atom3)
        assert_equal({atom1 => [atom2], atom2 => [atom1,atom3], atom3 => [atom2]}, molecule.atoms)
        molecule.addBond!(atom1,atom3)
        assert_equal({atom1 => [atom2, atom3], atom2 => [atom1,atom3], atom3 => [atom2,atom1]}, molecule.atoms)
    end

    def test_add_mol_simple
        atom1 = Atom.new
        atom2 = Atom.new
        molecule1 = Molecule.new
        molecule2 = Molecule.new
        molecule1.addAtom! atom1
        molecule2.addAtom! atom2
        molecule1.addMol! molecule2, atom1
        assert_equal({atom1 => [atom2], atom2 => [atom1]}, molecule1.atoms)
    end

    def test_add_mol_complex
        atom1 = Atom.new()
        atom2 = Atom.new()
        atom3 = Atom.new()
        atom4 = Atom.new()
        atom5 = Atom.new()
        atom6 = Atom.new()
        molecule1 = Molecule.new
        molecule2 = Molecule.new
        molecule1.addBond! atom1, atom2 
        molecule1.addBond! atom2, atom3 
        molecule1.addBond! atom3, atom4
        molecule2.addBond! atom5, atom6
        molecule1.addMol! molecule2, atom2
        atomAry = molecule1.atoms
        assert_equal(6, atomAry.size)
        assert_equal(1, atomAry[atom1].size)
        assert_equal(3, atomAry[atom2].size)
        assert_equal(2, atomAry[atom3].size)
        assert_equal(1, atomAry[atom4].size)
        assert_equal(2, atomAry[atom5].size)
        assert_equal(1, atomAry[atom6].size)
        assert(atomAry[atom2].include? atom5)
        assert(atomAry[atom2].include? atom1)
        assert(atomAry[atom5].include? atom2)
        assert(atomAry[atom5].include? atom6)
    end

    def test_find_path_simple
        atom1 = Atom.new()
        atom2 = Atom.new()
        molecule = Molecule.new()
        molecule.addAtom!(atom1)
        molecule.addAtom!(atom2)
        assert_equal([atom1],molecule.findLongestPath(atom1))
        molecule.addBond!(atom1,atom2)
        assert_equal([atom1, atom2], molecule.findLongestPath(atom1))
    end

    def test_find_path_long
        atom1 = Atom.new()
        atom2 = Atom.new()
        atom3 = Atom.new()
        atom4 = Atom.new()
        atom5 = Atom.new()
        atom6 = Atom.new()
        molecule = Molecule.new()
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom4,atom5)
        molecule.addBond!(atom5,atom6)
        assert_equal([atom1,atom2,atom3,atom4,atom5,atom6], molecule.findLongestPath(atom1))
    end

    def test_find_path_branched
        atom1 = Atom.new()
        atom2 = Atom.new()
        atom3 = Atom.new()
        atom4 = Atom.new()
        atom5 = Atom.new()
        atom6 = Atom.new()
        atom7 = Atom.new()
        molecule = Molecule.new()
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom2,atom5)
        molecule.addBond!(atom5,atom6)
        molecule.addBond!(atom6,atom7)
        assert_equal([atom1,atom2,atom5,atom6,atom7], molecule.findLongestPath(atom1))
        assert_equal([atom4,atom3,atom2,atom5,atom6,atom7], molecule.findLongestPath(atom4))

    end

    def test_find_path_branched_1
        # Test CCCC(CC)C
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom4,atom5)
        molecule.addBond!(atom5,atom6)
        molecule.addBond!(atom4,atom7)
        assert_equal([atom1, atom2, atom3, atom4, atom5, atom6], molecule.findLongestPath(atom1))
    end

    def test_find_path_branched_2
        atom1 = Atom.new()
        atom2 = Atom.new()
        atom3 = Atom.new()
        atom4 = Atom.new()
        atom5 = Atom.new()
        atom6 = Atom.new()
        atom7 = Atom.new()
        atom8 = Atom.new()
        molecule = Molecule.new()
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom3,atom5)
        molecule.addBond!(atom5,atom6)
        molecule.addBond!(atom2,atom7)
        molecule.addBond!(atom7,atom8)
        assert_equal([atom1,atom2,atom3,atom5,atom6], molecule.findLongestPath(atom1))
        assert_equal([atom8,atom7,atom2,atom3,atom5,atom6], molecule.findLongestPath(atom8))

    end

    def test_find_parent_string_simple
        atom1 = Atom.new()
        molecule = Molecule.new()
        molecule.addAtom!(atom1)
        assert_equal([atom1], molecule.findParentString)
    end

    def test_find_parent_string_long
        atom1 = Atom.new()
        atom2 = Atom.new()
        atom3 = Atom.new()
        atom4 = Atom.new()
        atom5 = Atom.new()
        atom6 = Atom.new()
        molecule = Molecule.new()
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom4,atom5)
        molecule.addBond!(atom5,atom6)
        assert_equal([atom1,atom2,atom3,atom4,atom5,atom6], molecule.findParentString)
    end

    def test_find_parent_string_branched_1
        # Test CCCC(CC)C
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom4,atom5)
        molecule.addBond!(atom5,atom6)
        molecule.addBond!(atom4,atom7)
        assert_equal(6, molecule.findParentString.size)
        assert_equal([atom1, atom2, atom3, atom4, atom5, atom6], molecule.findParentString)
    end

    def test_find_parent_string_branched_2
        # Test CC(CC)CCC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom2, atom6
        molecule.addBond! atom6, atom7
        assert_equal(6, molecule.findParentString.size)
        assert_equal([atom5, atom4, atom3, atom2, atom6, atom7], molecule.findParentString)
    end

    def test_find_parent_string_branched_3
        # Test CCC(CC)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom3, atom6
        molecule.addBond! atom6, atom7
        assert_equal(5, molecule.findParentString.size)
        assert_equal([atom1, atom2, atom3, atom4, atom5], molecule.findParentString)
    end

    def test_find_parent_branched_4
        # Test CC(CC)C(C)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        atom8 = Atom.new
        molecule = Molecule.new
        molecule.addBond!(atom1,atom2)
        molecule.addBond!(atom2,atom3)
        molecule.addBond!(atom3,atom4)
        molecule.addBond!(atom3,atom5)
        molecule.addBond!(atom5,atom6)
        molecule.addBond!(atom2,atom7)
        molecule.addBond!(atom7,atom8)
        assert_equal([atom6,atom5,atom3,atom2,atom7,atom8], molecule.findParentString)
    end

    def test_find_parent_branched_5
        # test CCC(C(C)C)CCC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        atom8 = Atom.new
        atom9 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3 
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom4, atom6
        molecule.addBond! atom3, atom7
        molecule.addBond! atom7, atom8
        molecule.addBond! atom8, atom9
        parent = molecule.findParentString
        assert_equal(2, molecule.countSubst(parent))
    end

    def test_copy_molecule
        # test CCC(C(C)C)CCC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        atom8 = Atom.new
        atom9 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3 
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom4, atom6
        molecule.addBond! atom3, atom7
        molecule.addBond! atom7, atom8
        molecule.addBond! atom8, atom9

        # Check breaking off one atom
        newMol = molecule.copyMolecule atom2, atom1
        assert_equal(8, newMol.size)
        atoms = newMol.atoms
        assert_equal([atom3], atoms[atom2])
        atoms.each do | atom, bonds |
            if atom == atom2 then
                next 
            end
            bonds.each do | bond |
                molecule.atoms[atom].include? bond
            end
        end

        # Check copying substituent
        newMol = molecule.copyMolecule atom4, atom3
        assert_equal(3, newMol.size)
        atoms = newMol.atoms
        assert_equal(2, atoms[atom4].size)
        assert(atoms[atom4].include? atom5)
        assert(atoms[atom4].include? atom6)
        atoms.each do | atom, bonds |
            if atom == atom2 then
                next 
            end
            bonds.each do | bond |
                molecule.atoms[atom].include? bond
            end
        end
    end
end


class TestMoleculeSubstituents < Test::Unit::TestCase
    def test_get_substituents_simple
        # test CCC(C)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom3, atom5
        molecule.addBond! atom5, atom6
        parent = molecule.findParentString
        substs = molecule.getSubstituents atom3, parent
        assert_equal(1, substs.size)
        atoms = substs[0].atoms
        assert_equal([], atoms[atom4])
        substs = molecule.getSubstituents atom2, parent
        assert_equal(0, substs.size)
    end

    def test_get_substituents_multi
        # test CCC(C)(C)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom3, atom5
        molecule.addBond! atom3, atom6
        molecule.addBond! atom6, atom7
        parent = molecule.findParentString
        substs = molecule.getSubstituents atom3, parent
        assert_equal(2, substs.size)
        
    end

    def test_get_substituents_branched
        # test CCC(C(C)C)CCC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        atom8 = Atom.new
        atom9 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3 
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom4, atom6
        molecule.addBond! atom3, atom7
        molecule.addBond! atom7, atom8
        molecule.addBond! atom8, atom9
        parent = molecule.findParentString
        substs = molecule.getSubstituents atom3, parent
        assert_equal(1, substs.size)
        newMol = substs[0]
        assert_equal(2, newMol.size)
        substs = molecule.getSubstituents atom4, parent
        assert_equal(1, substs.size)
        newMol = substs[0]
        assert_equal(1, newMol.size)
    end

    def test_process_parent_string_simple
        # test CCC(C)CCC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom3, atom5
        molecule.addBond! atom5, atom6
        molecule.addBond! atom6, atom7
        parent = molecule.findParentString
        assert_equal(atom1, parent[0])
        substs = molecule.processParentString parent
        assert_equal(1, substs.size)
        assert_equal(1, substs[atom3].size)
        assert_equal(atom1, parent[0])
    end

    def tests_process_parent_string_reverse
        # CCCC(C)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom5, atom6
        molecule.addBond! atom4, atom7
        parent = molecule.findParentString
        assert_equal(atom1, parent[0])
        substs = molecule.processParentString parent
        assert_equal(1, substs.size)
        assert_equal(atom6, parent[0])
    end

    def test_process_parent_dont_reverse
        # CC(C)CC(C)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        atom8 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom5, atom6
        molecule.addBond! atom4, atom7
        molecule.addBond! atom2, atom8
        parent = molecule.findParentString
        assert_equal(atom1, parent[0])
        substs = molecule.processParentString parent
        assert_equal(2, substs.size)
        assert_equal(atom1, parent[0])
    end

    def test_process_parent_reverse_alphabetical
        # CCCC(C)C(CC)CCC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        atom7 = Atom.new
        atom8 = Atom.new
        atom9 = Atom.new
        atom10 = Atom.new
        atom11 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom5, atom6
        molecule.addBond! atom6, atom7
        molecule.addBond! atom7, atom8
        molecule.addBond! atom4, atom9
        molecule.addBond! atom5, atom10
        molecule.addBond! atom10, atom11
        parent = molecule.findParentString
        assert_equal(atom1, parent[0])
        substs = molecule.processParentString parent
        assert_equal(2, substs.size)
        assert_equal(atom8, parent[0])
    end

    def test_process_parent_multiple
        # test CC(C)(C)CC
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom3, atom4
        molecule.addBond! atom2, atom5
        molecule.addBond! atom2, atom6
        parent = molecule.findParentString
        substs = molecule.processParentString parent
        assert_equal(1, substs.size)
        assert_equal(2, substs[atom2].size)
    end

    def test_process_parent_first_atom
        # test C(C)C
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom1, atom3
        parent = [atom1, atom3]
        substs = molecule.processParentString parent
        assert_equal(1, substs.size)
        assert_equal(1, substs[atom1].size)
        assert(substs[atom1][0].atoms.key? atom2)
    end

    def test_process_parent_first_atom_2
        # test C(CC)C(C)C
        atom1 = Atom.new
        atom2 = Atom.new
        atom3 = Atom.new
        atom4 = Atom.new
        atom5 = Atom.new
        atom6 = Atom.new
        molecule = Molecule.new
        molecule.addBond! atom1, atom2
        molecule.addBond! atom2, atom3
        molecule.addBond! atom1, atom4
        molecule.addBond! atom4, atom5
        molecule.addBond! atom2, atom6
    end
end

