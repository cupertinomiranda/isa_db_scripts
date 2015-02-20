class ReplacementMask
  include DataMapper::Resource

  property :id,   Serial
  property :mask, String
  property :name, String

  has n, :instruction_operands

  def number_of_bits
    mask.split('').select { |b| b != '0' }.count
  end

  def self.create_with_string(string)
    data = string.split(/[\s\t]+/)
    ReplacementMask.create({
      name: data[0],
      mask: data[1]
    })
  end
  def self.initialize_table
    self.create_with_string("none     00000000000000000000000000000000")

    self.create_with_string("bits8    11111111")
    self.create_with_string("bits16   1111111111111111")
    self.create_with_string("bits24   111111111111111111111111")
    self.create_with_string("word32   11111111111111111111111111111111")

    self.create_with_string("disp21h  00000111111111102222222222000000")
    self.create_with_string("disp21w  00000111111111002222222222000000")

    self.create_with_string("disp25h  00000111111111102222222222003333")
    self.create_with_string("disp25w  00000111111111002222222222003333")

    self.create_with_string("disp9    00000000000000000000000111111111")
    self.create_with_string("disp9ls  00000000111111112000000000000000")

    self.create_with_string("disp9s   0000000111111111")

    self.create_with_string("disp13s  0000011111111111")
  end
end
