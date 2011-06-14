require 'find'
require 'fast_stemmer'
require 'classifier'
require 'madeleine'

module AutoFile
  class DocumentFiler
    attr_accessor :storage_dir

    def initialize(storage_dir = nil)
      @storage_dir = storage_dir || default_storage_dir
      @storage = SnapshotMadeleine.new(storage) {
          Classifier::Bayes.new
      }
    end

    def add(directory, file)
      directory = directory.dup
      directory.extend PlainCategoryName
      classifier.add_category(directory) unless classifier.categories.include?(directory)
    end

    def categories
      classifier.categories
    end

    module PlainCategoryName
      def prepare_category_name
        to_s.intern
      end
    end

    private
      def default_storage_dir
        File.expand_path('~/.autofile')
      end

      def storage
        File.join(@storage_dir, 'classifier')
      end

      def classifier
        @storage.system
      end

      def words(file)
        `pdftotext "#{file}" -`
      end
  end
end
