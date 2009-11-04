module DataCatalog
  
  # TODO: add unit tests
  class Search
    
    REMOVE_CHARS = %r([!.;])
    
    STOP_WORDS = %w(
      a
      about
      are
      as
      at
      be
      by
      data
      for
      from
      how
      in
      is
      it
      of
      on
      or
      set
      that
      the 
      this
      to
      was
      what
      when
      where
      an
      who
      will
      with
      the
    )
    
    # Returns an array of strings, tokenized with stopwords removed.
    #
    # @param [<String>] array
    #   An array of strings
    #
    # @return [<String>]
    def self.process(array)
      unstop(tokenize(array))
    end
    
    # Tokenize an array of strings.
    #
    # @param [<String>] array
    #   An array of strings
    #
    # @return [<String>]
    def self.tokenize(array)
      array.reduce([]) do |m, x|
        m << tokens(x)
      end.flatten.uniq
    end
    
    # Tokenize a string, removing extra characters too.
    #
    # Problems with current implementation:
    #   * floating point numbers
    #     * for example, 98.6 will be split into 98 and 6
    #   # everything converted to lowercase
    #
    # @param [String] string
    #
    # @return [<String>]
    def self.tokens(string)
      if string
        string.downcase.gsub(REMOVE_CHARS, ' ').split(' ')
      else
        []
      end
    end

    # Remove stopwords from an array of strings.
    #
    # @param [<String>] array
    #   An array of strings
    #
    # @return [<String>]
    def self.unstop(array)
      array - STOP_WORDS
    end
    
  end
  
end
