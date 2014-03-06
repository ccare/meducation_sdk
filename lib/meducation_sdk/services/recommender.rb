module MeducationSDK
  class Recommender
    include Helpers

    def self.recommend(item, options = {})
      new(item, options).recommend
    end

    attr_reader :item
    def initialize(item, options = {})
      @item = item
      @options = options
    end

    def recommend
      generate_recommendations
    rescue => e
      log_error("!!Recommender Error!!")
      log_error(e.message)
      log_error(e.backtrace)
      #Item::Recommendation.where(item_type: @item.class.name).where(item_id: @item.id).includes(:recommendation).map(&:recommendation)
      []
    end

    def generate_recommendations
      groupings = {}
      correct_order = recommender_results.map do |result|
        groupings[result['type']] ||= []
        groupings[result['type']] << result['id']
        "#{result['type']}##{result['id']}"
      end

      output = groupings.map {|(type, ids)| sdk_class_for(type).where(id: ids) }.flatten
      output.sort_by!{ |item| correct_order.index("#{item.class.name}##{item.id}") }
      output
    end

    def recommender_results
      @recommender_results ||= begin
        results = JSON.parse(recommender_json)
        if @options[:limit]
          results[0..(@options[:limit] - 1)]
        else
          results
        end
      end
    end

    def recommender_json
      path = "/#{spi_type_for(item.class.name)}/#{item.id}"
      log "Calling #{config.recommender_host}:#{config.recommender_host}#{path}"
      response = Net::HTTP.get_response(config.recommender_host, path, config.recommender_port)
      body = response.body
      log "Received #{body}"
      body
    end

    def log(*args)
      config.logger.info(*args)
    end

    def log_error(*args)
      config.logger.error(*args)
    end

    def config
      MeducationSDK.config
    end
  end
end
