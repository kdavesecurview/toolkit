# frozen_string_literal: true

require "json"
require "rest_client"
require "base64"
module Kenna
  module Toolkit
    module QualysWasHelper
      def qualys_was_get_token(username, password)
        auth_details = "#{username}:#{password}"
        Base64::encode64(auth_details)
      end

      def qualys_was_get_webapp(token, qualys_was_url = 'qualysapi.qg3.apps.qualys.com/qps/rest/3.0/')
        print "Getting Webapp \n"
        qualys_was_auth_api = "https://#{qualys_was_url}search/was/webapp"
        # auth_headers = { "content-type" => "application/json",
        #            "accept" => "application/json" }
        # auth_body = { "id" => "administrator",
        #              "password" => "My@rvgicmx1" }


        @headers = {
          "Content-Type" => "application/json",
          "accept" => "application/json",
          "Authorization" => "Basic #{token}"}
        payload = {
           "ServiceRequest" => {
              "preferences" => {
                  "verbose" => "true",
                  "limitResults": "100"
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

      def qualys_was_get_webapp_findings(webapp_id, token, qualys_was_url = 'qualysapi.qg3.apps.qualys.com/qps/rest/3.0/')
        print_debug "Getting Webapp Findings For #{webapp_id} \n"
        qualys_was_auth_api = "https://#{qualys_was_url}search/was/finding"
        # auth_headers = { "content-type" => "application/json",
        #            "accept" => "application/json" }
        # auth_body = { "id" => "administrator",
        #              "password" => "My@rvgicmx1" }


        @headers = {
          "Content-Type" => "application/json",
          "accept" => "application/json",
          "Authorization" => "Basic #{token}"}

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

      def qualys_was_get_vuln(qids, token, qualys_was_url = 'qualysapi.qg3.apps.qualys.com/api/2.0/fo/')
        print "Getting Webapp Findings For #{qids} \n"
        qualys_was_auth_api = URI("https://#{qualys_was_url}knowledge_base/vuln/")
        # auth_headers = { "content-type" => "application/json",
        #            "accept" => "application/json" }
        # auth_body = { "id" => "administrator",
        #              "password" => "My@rvgicmx1" }


        @headers = {
          "Content-Type" => "application/json",
          "accept" => "application/json",
          "Authorization" => "Basic #{token}",
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
