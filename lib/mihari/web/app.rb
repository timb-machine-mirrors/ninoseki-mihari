require "awrence"
require "launchy"
require "rack"
require "sinatra"
require "sinatra/json"
require "sinatra/reloader"

module Mihari
  class App < Sinatra::Base
    register Sinatra::Reloader

    set :root, File.dirname(__FILE__)
    set :public_folder, proc { File.join(root, "public") }

    get "/" do
      send_file File.join(settings.public_folder, "index.html")
    end

    get "/api/alerts" do
      page = params["page"] || 1
      page = page.to_i
      limit = 10

      artifact_data = params["artifact"]
      description = params["description"]
      source = params["source"]
      tag_name = params["tag"]
      title = params["title"]

      from_at = params["from_at"] || params["fromAt"]
      from_at = DateTime.parse(from_at) if from_at
      to_at = params["to_at"] || params["toAt"]
      to_at = DateTime.parse(to_at) if to_at

      alerts = Mihari::Alert.search(
        artifact_data: artifact_data,
        description: description,
        from_at: from_at,
        limit: limit,
        page: page,
        source: source,
        tag_name: tag_name,
        title: title,
        to_at: to_at
      )
      total = Mihari::Alert.count(
        artifact_data: artifact_data,
        description: description,
        from_at: from_at,
        source: source,
        tag_name: tag_name,
        title: title,
        to_at: to_at
      )

      json = {alerts: alerts, total: total, current_page: page, page_size: limit}
      json json.to_camelback_keys
    end

    delete "/api/alerts/:id" do
      id = params["id"]
      id = id.to_i

      begin
        alert = Mihari::Alert.find(id)
        alert.destroy

        status 204
        body ""
      rescue ActiveRecord::RecordNotFound
        status 404

        message = {message: "ID:#{id} is not found"}
        json message
      end
    end

    delete "/api/artifacts/:id" do
      id = params["id"]
      id = id.to_i

      begin
        alert = Mihari::Artifact.find(id)
        alert.delete

        status 204
        body ""
      rescue ActiveRecord::RecordNotFound
        status 404

        message = {message: "ID:#{id} is not found"}
        json message
      end
    end

    get "/api/sources" do
      tags = Mihari::Alert.distinct.pluck(:source)
      json tags
    end

    get "/api/tags" do
      tags = Mihari::Tag.distinct.pluck(:name)
      json tags
    end

    get "/api/config" do
      report = Status.check

      json report.to_camelback_keys
    end

    class << self
      def run!(port: 9292, host: "localhost")
        Launchy.open "http://#{host}:#{port}"

        Rack::Handler::WEBrick.run self, Port: port, Host: host do |server|
          [:INT, :TERM].each do |sig|
            trap(sig) do
              server.shutdown
            end
          end
        end
      end
    end
  end
end