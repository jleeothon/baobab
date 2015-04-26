module Baobab

  module Shannon

      def self.entropy *probabilities
          probabilities.reduce(0) do |memo, p|
              if p.zero? then 0 else memo + self.entropy_term(p) end
          end
      end

      def self.entropy_term probability
          - probability * Math::log2(probability)
      end
  end

end
