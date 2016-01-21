require 'set'

class Spellchecker

  
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)
  def initialize(text_file_name)
    #read file text_file_name
    @dictionary = Hash.new(0)
    File.open(text_file_name,"r").each do |f|
    #extract words from string (file contents) using method 'words' below.
    #put in dictionary with their frequency (calling train! method)
    train!(words(f))
    end
  end

  def dictionary
    #getter for instance attribute
    return @dictionary.to_hash
  end
  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}. Default count should be 0 (argument of Hash constructor).
  
    word_list.each do |word|
        tempc = 1
        if @dictionary.has_key?(word)
            @dictionary[word] +=1
        else
              @dictionary.store(word,tempc)
        end
    end
  end

  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
        @dictionary[word]
      
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)
    deletes = Array.new(0)
    @i = 0
    word.each_char do |wlet|
      @tempword = String.new(word)
      @tempword.slice!(@i)
      deletes.insert(-1,@tempword)
      @i += 1 
    end
    #all strings obtained by deleting a letter (each letter)
    transposes = Array.new(0)
    @i=0
    word.each_char do |wlet|
      if @i+1 < word.size #will skip the last letter of the word so to not try and change with something out of the index.
      @tempword = String.new(word)
      @templett = String.new(@tempword.slice!(@i+1))
      @tempword.insert(@i,@templett)
      transposes.insert(-1,@tempword)
    end
     @i+=1
    end
    #all strings obtained by switching two consecutive letters
    inserts = Array.new(0)
    @i = 0
    word.each_char do |wlet|
        ALPHABET.each_char do |alet|
          @tempword = String.new(word)
          @tempword.insert(@i,alet)
          inserts.insert(-1,@tempword)
          #Statement to verify if at the last charcter of the word. add a letter of the alphabet to both beginings and ends. ie. hello would have hellao then helloa
          if @i+1 == word.size
            @tempword = String.new(word)
            @tempword.insert(@i+1,alet)
            inserts.insert(-1,@tempword)
          end
      end
     @i += 1 
    end
    # all strings obtained by inserting letters (all possible letters in all possible positions)
    replaces = Array.new(0)
    #all strings obtained by replacing letters (all possible letters in all possible positions)
    @i = 0
    word.each_char do |wlet|
        ALPHABET.each_char do |alet|
          @tempword = String.new(word)
          @tempword.slice!(@i)
          @tempword.insert(@i,alet)
          inserts.insert(-1,@tempword)
      end
     @i += 1 
    end
    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
      retA = Array.new(0)
      edits1(word).each do |obj|
        known(edits1(obj)).each do |obj_x|
          if retA.rindex(obj_x) == nil
            retA.insert(-1,obj_x)
          end
        end
      end
      return retA
  end

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
    return words.find_all {|word| lookup(word) > 0 } #find all words for which condition is true,
                                    #you need to figure out this condition
    
  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil
  def correct(word)
    
    retA = Array.new(0)
    tempArray = Array.new(known([word]))
    if tempArray.size > 0
      retA = Array.new(tempArray)
    else 
      tempArray = Array.new(known(edits1(word)))
      if tempArray.size >0
        @c=0
        tempArray.each do |tword|
          if retA.size >0
            retA.each do |rword|
              if lookup(tword) >lookup(rword)
                  @c = retA.rindex(rword)
                  break
              end
              @c +=1
            end
            if(retA.rindex(tword) == nil)
                   retA.insert(@c,tword)
              end
          else
            retA.insert(0,tword)    
          end
        end
      else
        tempArray = Array.new(known(known_edits2(word)))
        if tempArray.size >0
          @c=0
          tempArray.each do |tword|
            if retA.size >0
              retA.each do |rword|
                if lookup(tword) > lookup(rword)
                  @c = retA.rindex(rword)
                  break
                
                end
                @c +=1
              end
              if(retA.rindex(tword) == nil)
                   retA.insert(@c,tword)
              end
            else
              retA.insert(0,tword)    
            end
          end  
        else
          retA = nil 
        end
          
      end
    end
    return retA
  end
    
  
end

