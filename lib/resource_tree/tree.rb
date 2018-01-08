module ResourceTree
  class Tree
    attr_accessor :folder, :file, :filter
    attr_reader :generator

    IDENTITY = ->(path) { { resource: path } }

    def initialize(generator:, folder: IDENTITY, file: IDENTITY, filter: nil, children_key: :children)
      @generator = generator
      @folder = folder
      @file = file
      @filter = filter || ->(_) { true }
      @children_key = children_key
    end

    def call(path)
      tree(path)
    end

    private

    def tree(root_path)
      entries = generator.(root_path)
      entry = {}
      if array_with_items?(entries)
        entry = entry.merge(folder.(root_path))
        children = if entries.empty?
                     []
                   else
                     entries.reduce([]) { |a, e| a + [tree(path_from_root(root_path, e))] }
                   end
        entry.merge(@children_key => children.compact)
      elsif filter.(root_path)
        entry.merge(file.(root_path))
      end
    end

    def array_with_items?(entries)
      if entries.nil?
        false
      elsif entries.is_a?(Array)
        true
      end
    end

    def path_from_root(root_path, entry_path)
      if root_path == '.'
        entry_path
      else
        File.join(root_path, entry_path)
      end
    end
  end
end
