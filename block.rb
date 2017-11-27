require 'colorize'
require 'digest'

class Block
  attr_reader :msg, :prev_block_hash, :block_hash
  NUM_ZEROES = 5

  def initialize(prev_block, msg)
    @msg = msg
    @prev_block_hash = prev_block.block_hash if prev_block
    mine_block!
  end

  def self.create_genesis_block(msg)
    Block.new(nil, msg)
  end

  def mine_block!
    @nonce = find_nonce
    @block_hash = hash(block_contents + @nonce)
  end

  def block_contents
    [@prev_block_hash, @msg].compact.join
  end

  private
    def hash(message)
      Digest::SHA256.hexdigest(message)
    end

    def find_nonce
      nonce = "HELP I'M TRAPPED IN A NONCE FACTORY"
      count = 0
      until is_valid_nonce?(nonce)
        puts '.' if count % 100_000 == 0
        nonce = nonce.next
        count =+ 1
      end
      nonce
    end

    def is_valid_nonce?(nonce)
      hash(block_contents + nonce).start_with?("0" * NUM_ZEROES)
    end

    def to_s
      [
        "",
        "-" * 80,
        "Previous hash: ".rjust(15) + @prev_block_hash.to_s.yellow,
        "Message: ".rjust(15) + @msg.green,
        "Nonce: ".rjust(15) + @nonce.red,
        "Own hash: ".rjust(15) + @block_hash.yellow,
        "-" * 80,
        "|".rjust(40),
        "|".rjust(40),
        "↓".rjust(40),
      ].join("\n")
    end

end

class BlockChain
  attr_reader :blocks
  def initialize(msg)
    @blocks = [Block.create_genesis_block(msg)]
  end

  def add_to_chain(msg)
    @blocks << Block.new(@blocks.last, msg)
    puts @blocks.last
  end

  def valid?
    @blocks.all? { |block| block.is_a?(Block) } &&
      @blocks.all?(&:valid?) &&
        @blocks.each_cons(2).all? { |a, b| a.block_hash == b.prev_block_hash }
  end

  def to_s
    @blocks.map(&:to_s).joins("\n")
  end
end

b = BlockChain.new('----GENESIS BLOCK-----')
b.add_to_chain('Cinderella')
b.add_to_chain('The Three Stooges')
b.add_to_chain('Snow White')
