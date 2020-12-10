require_relative "constants"
require_relative "atom"
require_relative "parsingError"

class Molecule
    def initialize()

        # adjacency list containing all the bonds in the molecule. 
        # Format:
        #   {atom => [ <list of atoms> ]}
        @atoms = {}
    end

    def addAtom!(atom)
        atoms[atom] = [] unless atoms.key?(atom)
    end

    # Adds a bond between atom1 and atom2 into the adjacency list.
    # Adds the atoms to the molecule if they are not currently present
    # Params:
    #   atom1: key atom for the atom list
    #   atom2: value for the atom list
    # Returns: nothing
    def addBond!(atom1, atom2)
        if atom1 == nil or atom2 == nil
            return 
        end
        addAtom!(atom1)
        addAtom!(atom2)
        @atoms[atom1].push(atom2)
        @atoms[atom2].push(atom1)
    end

    # Adds a new molecule at a given position.
    # Params: 
    #   newMol: molecule to add
    #   atomSelf: where in current molecule to attach new molecule.
    #   atomOther: where in new molecule to attach.
    #              If not provided, first atom in atom hash is used
    def addMol!(newMol, atomSelf, atomOther = nil)
        if atomOther == nil then
            atomOther = newMol.atoms.keys[0]
        end
        @atoms.merge! newMol.atoms
        addBond! atomSelf, atomOther
    end

    # Get name of molecule without suffix
    def getIncompleteName(firstAtom = [])
        name = ""
        parent = findParentString(firstAtom)
        name = getHydroPfix(parent.length)
        prefix = getPrefix(parent)
        name = prefix + name unless prefix == nil
        name
    end

    # Get molecule prefix by looking at substituents
    def getPrefix(parent)
        prefix = ""
        subst_Pfix = Constants::SUBST_PFIX.invert
        substituents = processParentString(parent)
        return unless substituents.size > 0
        substNames = {}
        substituents.each do | atom, substs |
            substs.each do | subst |
                substNames[atom] = [] unless substNames[atom] != nil
                substNames[atom].push(subst.getSubstName)
            end
        end
        occurrences = {}
        substNames.each do | atom, nameArr |
            nameArr.each do | substName |
                occurrences[substName] = [] unless occurrences[substName] != nil 
                occurrences[substName].concat(parent.each_index.select { |p_idx| parent[p_idx] == atom})
            end
        end
        alphabetize = occurrences.keys.sort
        alphabetize.each_index do | idx |
            if idx > 0 then prefix += "-" end
            substName = alphabetize[idx]
            occurrences[substName].sort!
            occurrences[substName].each_index do |occr|
                if occr > 0 then prefix += "," end
                prefix += (occurrences[substName][occr] + 1).to_s
            end
            prefix += "-"
            if occurrences[substName].length > 1 then
                if occurrences[substName].length > subst_Pfix.size + 1 then
                    prefix += occurrences[substName].length # If prefix isn't implemented, just add number
                else
                    prefix += subst_Pfix[occurrences[substName].length]
                end
            end
            prefix += substName
        end
        prefix
    end

    # Get full name of molecule
    def calcIUPACname
        getIncompleteName + Constants::ALKANE_SFIX
    end

    # Get name of the parent string of a molecule (no suffix)
    def getHydroPfix(len)
        name = ""
        hydro_pfix = Constants::HYDRO_PFIX.invert
        if len <= hydro_pfix.length
            name = hydro_pfix[len]
        else
            name = len + "-" # just add the number if we don't have the prefix for that molecule
        end
        name
    end

    # Returns name for molecule as if it were a substituent group
    def getSubstName
        root = @atoms.keys[0]
        str = getIncompleteName([root]) + Constants::SUBST_SFIX
        if str.include? "-" # add parentheses around name if complex molecule
            str.prepend "("
            str += ")"
        end
        str
    end

    # Finds longest string of atoms in molecule
    # Does not consider correct IUPAC direction
    # Returns: Ordered array of atoms
    def findParentString(endpoints = [])
        retAry = []
        if endpoints ==  []
            @atoms.each do | key, value |
                if value.length < 2 then
                    endpoints.push(key)
                end
            end
        end
        for i in 0...endpoints.length
            visited = []
            if i > 0 then 
                visited = endpoints.slice(0,i - 1) 
            end
            path = findLongestPath(endpoints[i], visited)
            if swapPaths?(retAry, path) then 
                retAry = path 
            end
        end
        retAry
    end

    def swapPaths?(retAry, path)
        if path.length > retAry.length then
            return true
        end
        if path.length == retAry.length then
           retCount = countSubst(retAry)
           pathCount = countSubst(path)
           return retCount < pathCount
        end
        false
    end

    # Counts number of substituents along a path
    def countSubst(path)
        count = 0
        path.each do | atom |
            if @atoms[atom].size > 2 then
                count += (@atoms[atom].size - 2)
            end
        end
        count
    end

    def findLongestPath(atom, visited = [])
        retAry = []
        retAry.push(atom)
        visited.push(atom)
        maxPath = []
        @atoms[atom].each do | bond |
            if !visited.include? bond
                curPath = findLongestPath(bond, visited)
                if swapPaths? maxPath, curPath
                    maxPath = curPath
                end
            end
        end
        retAry.concat(maxPath)
    end

    # Determines the substituent groups in the molecule based off the parent array.
    # Params:
    #   parent: an array of atoms in the molecule defining the parent chain
    # Returns: A hash  of format:
    #   {
    #       atom in parent chain => [array of molecules representing substituents]
    #   }
    def processParentString(parent)
        substs = {}
        iterator = 1
        firstSubstLoc = 0
        firstSubstLen = 0
        parent.each do | atom |
            bonds = @atoms[atom]
            if bonds.size > 1
                sub = getSubstituents(atom, parent)
                if sub.size > 0 then
                    substs[atom] = sub

                    # Get longest substituent for checking chain direction
                    length = 0
                    substs[atom].each do | mol |
                        if mol.size > length then length = mol.size end
                    end
                

                    # Check if this atom is the first atom in chain with substituent
                    if firstSubstLoc == 0
                        firstSubstLoc = iterator
                        firstSubstLen = length
                    elsif iterator > (parent.size / 2) then
                        if firstSubstLoc > parent.size / 2 then
                            firstSubstLoc = iterator
                        elsif (parent.size - iterator + 1) < firstSubstLoc then
                            firstSubstLoc = iterator
                        elsif (parent.size - iterator + 1) == firstSubstLoc then
                            firstSubstLoc = iterator unless !shouldFlip firstSubstLen, length
                        end
                    end
                end
            end
            iterator += 1
        end
        if firstSubstLoc > (parent.size / 2) then 
            parent.reverse! 
        end
        substs
    end

    def shouldFlip(firstLen, secondLen)
        firstPfix = getHydroPfix(firstLen)
        secondPfix = getHydroPfix(secondLen)
        (firstPfix <=> secondPfix) > 0
    end

    # Returns array of molecule objects referring to substituents
    def getSubstituents(atom, parents)
        retAry = []
        @atoms[atom].each do | bond |
            if !parents.include? bond then
                retAry.push(copyMolecule(bond, atom))
            end
        end
        retAry
    end

    # Makes a copy of a subset of the molecule's structure
    def copyMolecule(child, parent)
        molecule = Molecule.new
        molecule.addAtom! child
        @atoms[child].each do | bond |
            if bond != parent then
                molecule.addMol!(copyMolecule(bond, child), child)
            end
        end
        molecule
    end

    # Returns: atoms hash
    def atoms
        @atoms
    end

    # Returns: number of atoms in molecule
    def size
        @atoms.size
    end
end
