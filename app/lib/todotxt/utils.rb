class Todotxt
  module Utils
    class << self
      def delete_first(array, item = nil, &block)
        optional_args = [item, block_given?]
        if optional_args.none? || optional_args.all?
          raise InternalError.new("Either `item` or block must be passed")
        end

        item_index = if item
          array.index(item)
        elsif block_given?
          array.index(&block)
        end

        array.delete_at(item_index) if item_index
      end
    end
  end
end
