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

    def save
      @storage.take_snapshot
    end

    def add(directory, file)
      directory = directory.dup
      directory.extend PlainCategoryName
      if words = words(directory, file)
        classifier.add_category(directory) unless classifier.categories.include?(directory)
        classifier.train(directory, words)
      end
    end

    def categories
      classifier.categories
    end

    def directory_for(path)
      words = words(path)
      classifier.classify(words).to_s if words
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

      def words(directory_or_path, file = nil)
        path = file ? File.join(directory_or_path, file) : directory_or_path
        case File.extname(path)
        when '.txt'
          File.read(path)
        when '.pdf'
          `pdftotext "#{path}" -`
        end
      end
  end
end
