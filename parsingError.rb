class ParsingError < StandardError
    def initialize(msg = "There was an error parsing the SMILES input", type = "gen")
        @msg = msg
        @type = type
    end
    def msg
        @msg
    end
    def type
        @type
    end
end