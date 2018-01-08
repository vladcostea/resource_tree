class DirGenerator
  def initialize(base_path)
    @base_path = base_path
  end

  def call(path)
    abs_path = path == '.' ? base_path : File.join(base_path, path)
    return nil if File.file?(abs_path)
    Dir.entries(abs_path).reject(&unix)
  end

  attr_reader :base_path

  private

  def unix
    ->(path) { ['.', '..'].include?(path) }
  end
end

RSpec.describe ResourceTree::Tree do
  let(:dirpath) { File.dirname(__FILE__) }

  before(:each) do
    FileUtils.mkdir_p(File.join(dirpath, 'tmp', 'a', 'b'))
    FileUtils.mkdir_p(File.join(dirpath, 'tmp', 'a', 'c'))
    FileUtils.touch(File.join(dirpath, 'tmp', 'a', 'a0.txt'))
    FileUtils.touch(File.join(dirpath, 'tmp', 'a', 'a1.html'))
    FileUtils.touch(File.join(dirpath, 'tmp', 'a', 'b', 'b0.txt'))
  end

  after(:each) do
    FileUtils.rm_rf(File.join(dirpath, 'tmp'))
  end

  it 'maps the relative filesystem to a tree' do
    tree = described_class.new(
      generator: DirGenerator.new(dirpath),
      file: ->(path) {
        name = path.split('/').last
        { text: name, type: 'file', path: path }
      },
      folder: ->(path) {
        name = path.split('/').last
        { text: name, type: 'folder', path: path }
      }
    )

    expect(tree.call('tmp')).to eq({
      text: 'tmp', type: 'folder', path: 'tmp',
      children: [
        {
          text: 'a', type: 'folder', path: 'tmp/a',
          children: [
            {
              text: 'a0.txt', type: 'file', path: 'tmp/a/a0.txt'
            },
            {
              text: 'a1.html', type: 'file', path: 'tmp/a/a1.html'
            },
            {
              text: 'b', type: 'folder', path: 'tmp/a/b',
              children: [
                { 
                  text: 'b0.txt', type: 'file', path: 'tmp/a/b/b0.txt'
                }
              ]
            },
            {
              text: 'c', type: 'folder', path: 'tmp/a/c',
              children: []
            }
          ]    
        }
      ]
    })
  end
end
