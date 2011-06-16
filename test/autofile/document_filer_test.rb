require 'test_helper'
require 'fileutils'
require 'tmpdir'

class DocumentFilerTest < Test::Unit::TestCase
  def tmp_dir
    @tmp_dir ||= File.join(Dir.tmpdir, "autofile-test-#{Process.pid}")
  end

  def home_dir
    File.expand_path('~')
  end

  def fixture(name)
    File.join('fixtures', name)
  end

  attr_accessor :filer

  def new_filer
    @filer = AutoFile::DocumentFiler.new(tmp_dir)
  end

  def close_filer
    @filer.save
    @filer = nil
  end

  def teardown
    FileUtils.rm_rf tmp_dir
    super
  end

  def add_known_documents
    2.times { |i| filer.add(fixture('leeds'), "statement_#{i+1}.txt") }
    3.times { |i| filer.add(fixture('york'), "statement_#{i+1}.txt") }
  end

  def assert_match_unknown_documents
    assert_equal fixture('leeds'), filer.directory_for(fixture('incoming/leeds_statement.txt'))
    assert_equal fixture('york'), filer.directory_for(fixture('incoming/york_statement.txt'))
  end

  def test_storage_persists
    new_filer
    add_known_documents
    close_filer

    new_filer
    assert_match_unknown_documents
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
    filer.add(fixture('leeds'), 'statement_1.txt')
    assert filer.categories.include?(fixture('leeds'))
  end

  def test_should_not_add_category_for_unknown_file_types
    filer.add(fixture('leeds'), 'unknown.extension')
    assert !filer.categories.include?(fixture('leeds'))
  end

  def test_should_classify_document
    add_known_documents
    assert_match_unknown_documents
  end

  def test_should_not_classify_unknown_file_types
    add_known_documents
    assert_nil filer.directory_for(fixture('leeds/unknown.extension'))
  end

  def test_should_provide_ranked_classifications_for_document
    add_known_documents
    suggestions = filer.directories_for(fixture('incoming/leeds_statement.txt'))
    assert_equal [fixture('leeds'), fixture('york')], suggestions
  end
end
