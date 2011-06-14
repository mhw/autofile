require 'test_helper'
require 'fileutils'
require 'tmpdir'

class DocumentFilerTest < Test::Unit::TestCase
  def tmp_dir
    @tmp_dir ||= Dir.tmpdir
  end

  def home_dir
    File.expand_path('~')
  end

  def fixture_dir(name)
    File.join('fixtures', name)
  end

  attr_accessor :filer

  def new_filer
    @filer = AutoFile::DocumentFiler.new(tmp_dir)
  end

  def teardown
    FileUtils.rm_rf tmp_dir
    super
  end

  def test_storage_persists
    new_filer
  end
end

class DocumentFilerBehaviourTest < DocumentFilerTest
  def setup
    super
    new_filer
  end

  def test_default_storage_dir
    assert_equal File.join(home_dir, '.autofile'), filer.send(:default_storage_dir)
  end

  def test_overridden_storage_dir
    assert_equal tmp_dir, filer.storage_dir
  end

  def test_should_add_directories_as_categories
    filer.add(fixture_dir('leeds'), 'statement_1.txt')
    assert filer.categories.include?(fixture_dir('leeds'))
  end
end
