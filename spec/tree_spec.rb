RSpec.describe ResourceTree::Tree do
  it 'returns the correct hash with default values' do
    fs = ->(path) {
      {
        'a' => %w[b e],
        'a/b' => %w[c d],
        'a/b/c' => nil,
        'a/b/d' => nil,
        'a/e' => nil
      }[path]
    }
    tree = described_class.new(generator: fs)

    expect(tree.call('a')).to eq({
      resource: 'a',
      children: [
        {
          resource: 'a/b',
          children: [{ resource: 'a/b/c' }, { resource: 'a/b/d' }]
        },
        {
          resource: 'a/e'
        }
      ]
    })
  end

  it 'returns the correct hash with custom mappers and filters' do
    fs = ->(path) {
      {
        'a' => %w[b],
        'a/b' => %w[c d],
        'a/b/.h' => nil,
        'a/b/c' => nil,
        'a/b/d' => nil,
      }[path]
    }
    tree = described_class.new(
      generator: fs,
      file: ->(path) {
        name = path.split('/').last
        { text: name, type: 'file', path: path }
      },
      folder: ->(path) {
        name = path.split('/').last
        { text: name, type: 'folder', path: path }
      },
      filter: ->(path) {
        path != 'a/b/d' || path.split('/').last.start_with?('.')
      },
      children_key: :nodes
    )

    expect(tree.call('a')).to eq({
      text: 'a',
      type: 'folder',
      path: 'a',
      nodes: [
        {
          text: 'b',
          type: 'folder',
          path: 'a/b',
          nodes: [{ text: 'c', type: 'file', path: 'a/b/c' }]
        }
      ]
    })
  end
end
