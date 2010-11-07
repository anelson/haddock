#!/usr/local/bin/ruby -w

WORDLIST = "c:/work/sourcecode/moby/mwords/354984si.ngl"
SYMBOLS = '`~!@#$%^&*()-_=+[{]}\\|;:\'",<.>/?'
LOG2 = Math.log(2)

def get_word_counts_by_length(wordfile)
    counts = Hash.new(0)

    File.open(wordfile) do |file|
        file.each_line do |line|
            counts[line.chomp.length]+=1
        end
    end

    counts
end

def get_permutations_for_length(length, word_counts_by_length)
    #To compute the strength, we just need to count the number of possible passwords
    #which can be generated for this length.  Since the algorithm involves picking two
    #random words and one random symbol, plus padding with decimal digits, it's actually
    #not that hard to compute
    
    length_lower_limit = length * 0.75
    length_upper_limit = length

    #The algorithm picks two random words and one random symbol repeatedly until the length
    #of the string formed by both words and the symbol falls between the upper and lower limit
    #If the resulting string is not exactly length chars long, random decimal digits are used to
    #make up the difference
    #
    #Thus, for each integer length between the two limits, figure out how many values can be generated
    num_passwords = 0
    (length_lower_limit.floor + 1..length_upper_limit-1).each do |words_length|
        #Not counting the random symbol which is one character, count how many word combos there are
        #that result in a string exactly this long
        num_word_combos = get_word_permute_count_for_length(words_length-1, word_counts_by_length)
        num_symbol_combos = SYMBOLS.length
        num_digit_combos = 10 * (length - words_length)

        num_passwords += (num_word_combos*num_symbol_combos*num_digit_combos)
    end

    num_passwords
end

def get_word_permute_count_for_length(length, word_counts_by_length) 
    #Figure out how many two-word permutations there are that result in a string of exactly length
    #characters.
    num_permuts = 0
    (1..length-1).each do |first_word_length|
        (1..(length-first_word_length)).each do |second_word_length|
            num_permuts += word_counts_by_length[first_word_length]*word_counts_by_length[second_word_length]
        end
    end

    num_permuts
end

word_counts_by_length = get_word_counts_by_length(WORDLIST)

(8..31).each do |length|
    num_permutations = get_permutations_for_length(length, word_counts_by_length)

    #num_permutations is the total number of possible passwords which can be generated for this length
    #convert it to a strength in bits by recognizing a key of strength n bits has the property that
    #a random such key could with equal probability take any one of 2^n possible values.  In our case
    #we know how many values, and we need to know n.  This is why God invented the base-2 logarithm, log2.
    #Ruby doesn't have a log2 function, so take advantage of log properties
    #that log2(x) = logn(x) / logn(2)
    strength_in_bits = Math.log(num_permutations) / LOG2

    print "For password length #{length}, "
    print "there are %.2e possibles, " % num_permutations
    print "strength is %.2f bits" % strength_in_bits
    puts
end

