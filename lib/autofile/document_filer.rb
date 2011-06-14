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
      classifier.add_category(directory) unless classifier.categories.include?(directory)
    end

    private
      def default_storage_dir
        File.expand_path('~/.autofile')
      end

      def storage
        File.join(@storage_dir, 'classifier')
      end

      def words(file)
        `pdftotext "#{file}" -`
      end
  end
end
