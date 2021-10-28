# frozen_string_literal: true

require "json"
require "rest_client"
require "base64"
module Kenna
  module Toolkit
    module QualysWasHelper
      def qualys_was_get_token(username = 'username', password = 'Password')
        auth_details = "#{username}:#{password}"
        Base64::encode64(auth_details)
      end

      def qualys_was_get_webapp(qualys_was_url = 'qualysapi.qg3.apps.qualys.com/qps/rest/3.0/')
        print "Getting Webapp \n"
        qualys_was_auth_api = "https://#{qualys_was_url}search/was/webapp"
        # auth_headers = { "content-type" => "application/json",
        #            "accept" => "application/json" }
        # auth_body = { "id" => "administrator",
        #              "password" => "My@rvgicmx1" }


        @headers = {
          "Content-Type" => "application/json",
          "accept" => "application/json",
          "Authorization" => "Basic #{qualys_was_get_token}"}
        payload = {
        }

        # print_debug "#{qualys_was_auth_api}"
        # print_debug "#{auth_headers}"
        # print_debug "#{auth_body}"
        auth_response = http_post(qualys_was_auth_api, @headers, payload.to_json)
        return nil unless auth_response

        begin
          response = JSON.parse(auth_response.body)
        rescue JSON::ParserError
          print_error "Unable to process Auth Token response!"
        end

        print response
        print "\n\n \n\n"
        response
      end

      def qualys_was_get_webapp_findings(webapp_id = '55778935', qualys_was_url = 'qualysapi.qg3.apps.qualys.com/qps/rest/3.0/')
        print "Getting Webapp Findings For #{webapp_id} \n"
        qualys_was_auth_api = "https://#{qualys_was_url}search/was/finding"
        # auth_headers = { "content-type" => "application/json",
        #            "accept" => "application/json" }
        # auth_body = { "id" => "administrator",
        #              "password" => "My@rvgicmx1" }


        @headers = {
          "Content-Type" => "application/json",
          "accept" => "application/json",
          "Authorization" => "Basic #{qualys_was_get_token}"}

        payload = {
          "ServiceRequest": {
              "preferences": {
                  "verbose": "true",
                  "limitResults": "100"
              },
              "filters": {
                  "Criteria": {
                      "field": "webApp.id",
                      "operator": "EQUALS",
                      "value": "#{webapp_id}"
                  }
              }
           }
        }

        # print_debug "#{qualys_was_auth_api}"
        # print_debug "#{auth_headers}"
        # print_debug "#{auth_body}"
        auth_response = http_post(qualys_was_auth_api, @headers, payload.to_json)
        return nil unless auth_response

        begin
          response = JSON.parse(auth_response.body)
        rescue JSON::ParserError
          print_error "Unable to process Auth Token response!"
        end

        print response
        print "\n\n \n\n"
        response
      end

      def qualys_was_get_vuln(qids = ['150082'], qualys_was_url = 'qualysapi.qg3.apps.qualys.com/api/2.0/fo/')
        print "Getting Webapp Findings For #{qids} \n"
        qualys_was_auth_api = URI("https://#{qualys_was_url}knowledge_base/vuln/")
        # auth_headers = { "content-type" => "application/json",
        #            "accept" => "application/json" }
        # auth_body = { "id" => "administrator",
        #              "password" => "My@rvgicmx1" }


        @headers = {
          "Content-Type" => "application/json",
          "accept" => "application/json",
          "Authorization" => "Basic #{qualys_was_get_token}",
          "X-Requested-With" => 'QualysPostman'
        }

        payload = {
          "action" => "list",
          "ids" => qids.join(',')
        }

        qualys_was_auth_api.query = URI.encode_www_form(payload)

        # print_debug "#{qualys_was_auth_api}"
        # print_debug "#{auth_headers}"
        # print_debug "#{auth_body}"
        auth_response = http_get("#{qualys_was_auth_api}", @headers)
        return nil unless auth_response

        begin
          #response = JSON.parse(auth_response.body)
        rescue JSON::ParserError
          #print_error "Unable to process Auth Token response!"
        end

        print auth_response.body
        print "\n\n \n\n"
        auth_response.body
      end

      def http_get(url, headers, max_retries = 5, verify_ssl = true)
        RestClient::Request.execute(
          method: :get,
          url: url,
          headers: headers,
          verify_ssl: verify_ssl
        )
      rescue RestClient::TooManyRequests => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          sleep(15)
          puts "Retrying!"
          retry
        end
      rescue RestClient::UnprocessableEntity => e
        puts "Exception! #{e}"
      rescue RestClient::BadRequest => e
        puts "Exception! #{e}"
      rescue RestClient::InternalServerError => e
        retries ||= 0
        if retries < max_retries
          retries += 1
          sleep(15)
          puts "Retrying!"
          retry
        end
        puts "Exception! #{e}"
      rescue RestClient::ServerBrokeConnection => e
        puts "Exception! #{e}"
      rescue RestClient::ExceptionWithResponse => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      rescue RestClient::NotFound => e
        puts "Exception! #{e}"
      rescue RestClient::Exception => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          sleep(15)
          puts "Retrying!"
          retry
        end
      rescue Errno::ECONNREFUSED => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      end

      def http_post(url, headers, payload, max_retries = 5, verify_ssl = true)
        RestClient::Request.execute(
          method: :post,
          url: url,
          headers: headers
        )
      rescue RestClient::TooManyRequests => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      rescue RestClient::UnprocessableEntity => e
        puts "Exception! #{e}"
      rescue RestClient::BadRequest => e
        puts "Exception! #{e}"
      rescue RestClient::InternalServerError => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      rescue RestClient::ServerBrokeConnection => e
        puts "Exception! #{e}"
      rescue RestClient::ExceptionWithResponse => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      rescue RestClient::NotFound => e
        puts "Exception! #{e}"
      rescue RestClient::Exception => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      rescue Errno::ECONNREFUSED => e
        puts "Exception! #{e}"
        retries ||= 0
        if retries < max_retries
          retries += 1
          puts "Retrying!"
          sleep(15)
          retry
        end
      end

      def qualys_was_get_containers(qualys_was_url, token, pagesize, pagenum)
        print_debug "Getting All Containers"
        qualys_was_cont_api = "http://#{qualys_was_url}/api/v2/containers?pagesize=#{pagesize}&page=#{pagenum}"
        puts "finding #{qualys_was_cont_api}"
        @headers = { "Content-Type" => "application/json",
                     "accept" => "application/json",
                     "Authorization" => "Bearer #{token}" }

        response = http_get(qualys_was_cont_api, @headers)
        return nil unless response

        begin
          json = JSON.parse(response.body)
        rescue JSON::ParserError
          print_error "Unable to process Containers response!"
        end

        json["result"]
      end

      def qualys_was_get_vuln_for_container(qualys_was_url, token, image, pagesize, pagenum)
        print_debug "Getting Vulnerabilities for a Container image"
        qualys_was_cont_img_api = "http://#{qualys_was_url}/api/v2/risks/vulnerabilities?image_name=#{image}&pagesize=#{pagesize}&page=#{pagenum}"
        puts "finding #{qualys_was_cont_img_api}"
        @headers = { "Content-Type" => "application/json",
                     "accept" => "application/json",
                     "Authorization" => "Bearer #{token}" }

        response = http_get(qualys_was_cont_img_api, @headers)
        return nil unless response

        begin
          json = JSON.parse(response.body)
        rescue JSON::ParserError
          print_error "Unable to process Image vulnerabilities for Containers response!"
        end

        json["result"]
      end
    end
  end
end


class A
  extend Kenna::Toolkit::QualysWasHelper
end

web_apps = A.qualys_was_get_webapp
web_apps_findings = {}
web_apps['ServiceResponse']['data'].each do |web_app|
  web_apps_findings[web_app['WebApp']['id']] = A.qualys_was_get_webapp_findings(web_app['WebApp']['id'])
end
web_apps_findings.each do |web_app, findings|
  p "QID For #{web_app}"
  qids = findings['ServiceResponse']['data'].map{|x| x['Finding']['qid']}

  A.qualys_was_get_vuln(qids)
end
#A.qualys_was_get_vuln
