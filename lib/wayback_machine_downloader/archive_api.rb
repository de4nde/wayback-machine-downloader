require 'json'
require 'open-uri'

module ArchiveAPI
  def get_raw_list_from_api(url, page_index)
    request_url = URI("https://web.archive.org/cdx/search/cdx")
    params = [["output", "json"], ["url", url]]
    params += parameters_for_api(page_index)
    request_url.query = URI.encode_www_form(params)
    
    begin
      open(request_url) do |response|
        json = JSON.parse(response.read)
        if (json[0] <=> ["timestamp","original"]) == 0
          json.shift
        end
        json
      end
    rescue OpenURI::HTTPError, JSON::ParserError => e
      puts "Error fetching data: #{e.message}"
      []
    rescue SocketError => e
      puts "Network error: #{e.message}"
      []
    end
  end
  
  def parameters_for_api(page_index)
    parameters = [["fl", "timestamp,original"], ["collapse", "digest"], ["gzip", "false"]]
    parameters.push(["filter", "statuscode:200"]) unless @all
    parameters.push(["from", @from_timestamp.to_s]) if @from_timestamp && @from_timestamp != 0
    parameters.push(["to", @to_timestamp.to_s]) if @to_timestamp && @to_timestamp != 0
    parameters.push(["page", page_index]) if page_index
    parameters
  end
end