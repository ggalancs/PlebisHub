# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  # Skip ApplicationController filters that may cause issues in testing
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Define a simple route for testing
    @routes ||= ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get '/show' => 'errors#show'
    end
  end

  describe "GET #show" do
    context "when no code parameter is provided" do
      it "assigns @code to default value '500' as string" do
        get :show
        expect(assigns(:code)).to eq("500")
      end

      it "renders the show template" do
        get :show
        expect(response).to render_template(:show)
      end

      it "returns http status 500 (internal_server_error)" do
        get :show
        expect(response).to have_http_status(:internal_server_error)
      end

      it "returns the correct numeric status code" do
        get :show
        expect(response.status).to eq(500)
      end
    end

    context "when code parameter is 404" do
      it "assigns @code to '404' as string" do
        get :show, params: { code: 404 }
        expect(assigns(:code)).to eq("404")
      end

      it "renders the show template" do
        get :show, params: { code: 404 }
        expect(response).to render_template(:show)
      end

      it "returns http status 404 (not_found)" do
        get :show, params: { code: 404 }
        expect(response).to have_http_status(:not_found)
      end

      it "returns the correct numeric status code" do
        get :show, params: { code: 404 }
        expect(response.status).to eq(404)
      end
    end

    context "when code parameter is 500" do
      it "assigns @code to '500' as string" do
        get :show, params: { code: 500 }
        expect(assigns(:code)).to eq("500")
      end

      it "renders the show template" do
        get :show, params: { code: 500 }
        expect(response).to render_template(:show)
      end

      it "returns http status 500 (internal_server_error)" do
        get :show, params: { code: 500 }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context "when code parameter is 422" do
      it "assigns @code to '422' as string" do
        get :show, params: { code: 422 }
        expect(assigns(:code)).to eq("422")
      end

      it "renders the show template" do
        get :show, params: { code: 422 }
        expect(response).to render_template(:show)
      end

      it "returns http status 422 (unprocessable_entity)" do
        get :show, params: { code: 422 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when code parameter is 403" do
      it "assigns @code to '403' as string" do
        get :show, params: { code: 403 }
        expect(assigns(:code)).to eq("403")
      end

      it "renders the show template" do
        get :show, params: { code: 403 }
        expect(response).to render_template(:show)
      end

      it "returns http status 403 (forbidden)" do
        get :show, params: { code: 403 }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when code parameter is a symbolic string" do
      it "assigns @code to the string value" do
        get :show, params: { code: "not_found" }
        expect(assigns(:code)).to eq("not_found")
      end

      it "renders the show template" do
        get :show, params: { code: "not_found" }
        expect(response).to render_template(:show)
      end

      it "converts the string to a symbol for status" do
        get :show, params: { code: "not_found" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when code parameter is zero" do
      it "assigns @code to '0' as string" do
        get :show, params: { code: 0 }
        expect(assigns(:code)).to eq("0")
      end

      it "renders the show template" do
        get :show, params: { code: 0 }
        expect(response).to render_template(:show)
      end

      it "returns http status 0 as integer" do
        get :show, params: { code: 0 }
        expect(response.status).to eq(0)
      end
    end

    context "when code parameter is nil explicitly" do
      it "assigns @code to default '500' as string" do
        get :show, params: { code: nil }
        expect(assigns(:code)).to eq("500")
      end

      it "renders the show template" do
        get :show, params: { code: nil }
        expect(response).to render_template(:show)
      end

      it "returns http status 500" do
        get :show, params: { code: nil }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context "when code parameter is an empty string" do
      it "assigns @code to default '500' as string (empty string is falsy)" do
        get :show, params: { code: "" }
        expect(assigns(:code)).to eq("500")
      end

      it "renders the show template" do
        get :show, params: { code: "" }
        expect(response).to render_template(:show)
      end

      it "returns http status 500" do
        get :show, params: { code: "" }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context "type consistency verification" do
      it "always returns @code as a String regardless of input" do
        test_cases = [
          { input: 404, expected: "404" },
          { input: "500", expected: "500" },
          { input: nil, expected: "500" },
          { input: "", expected: "500" },
          { input: 0, expected: "0" },
          { input: "not_found", expected: "not_found" }
        ]

        test_cases.each do |test_case|
          get :show, params: { code: test_case[:input] }
          expect(assigns(:code)).to be_a(String),
            "Expected @code to be String for input #{test_case[:input].inspect}, got #{assigns(:code).class}"
          expect(assigns(:code)).to eq(test_case[:expected])
        end
      end
    end

    context "http status code conversion" do
      it "converts numeric string codes to integer status codes" do
        numeric_codes = [404, 500, 422, 403, 503, 502]

        numeric_codes.each do |code|
          get :show, params: { code: code }
          expect(response.status).to eq(code)
        end
      end

      it "converts symbolic strings to symbol status codes" do
        symbolic_cases = [
          { input: "not_found", expected_status: 404 },
          { input: "internal_server_error", expected_status: 500 },
          { input: "unprocessable_entity", expected_status: 422 },
          { input: "forbidden", expected_status: 403 }
        ]

        symbolic_cases.each do |test_case|
          get :show, params: { code: test_case[:input] }
          expect(response.status).to eq(test_case[:expected_status]),
            "Expected status #{test_case[:expected_status]} for '#{test_case[:input]}', got #{response.status}"
        end
      end
    end
  end
end
