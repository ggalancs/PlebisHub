# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe "GET #show" do
    context "when no code parameter is provided" do
      it "assigns @code to default value 500" do
        get :show
        expect(assigns(:code)).to eq(500)
      end

      it "renders the show template" do
        get :show
        expect(response).to render_template(:show)
      end

      it "returns http success" do
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    context "when code parameter is 404" do
      it "assigns @code to 404" do
        get :show, params: { code: 404 }
        expect(assigns(:code)).to eq("404")
      end

      it "renders the show template" do
        get :show, params: { code: 404 }
        expect(response).to render_template(:show)
      end

      it "returns http success" do
        get :show, params: { code: 404 }
        expect(response).to have_http_status(:success)
      end
    end

    context "when code parameter is 500" do
      it "assigns @code to 500" do
        get :show, params: { code: 500 }
        expect(assigns(:code)).to eq("500")
      end

      it "renders the show template" do
        get :show, params: { code: 500 }
        expect(response).to render_template(:show)
      end
    end

    context "when code parameter is 422" do
      it "assigns @code to 422" do
        get :show, params: { code: 422 }
        expect(assigns(:code)).to eq("422")
      end

      it "renders the show template" do
        get :show, params: { code: 422 }
        expect(response).to render_template(:show)
      end
    end

    context "when code parameter is a custom value" do
      it "assigns @code to the provided value" do
        get :show, params: { code: 403 }
        expect(assigns(:code)).to eq("403")
      end

      it "renders the show template" do
        get :show, params: { code: 403 }
        expect(response).to render_template(:show)
      end
    end

    context "when code parameter is a string" do
      it "assigns @code to the string value" do
        get :show, params: { code: "not_found" }
        expect(assigns(:code)).to eq("not_found")
      end

      it "renders the show template" do
        get :show, params: { code: "not_found" }
        expect(response).to render_template(:show)
      end
    end

    context "when code parameter is zero" do
      it "assigns @code to 0 (falsy value)" do
        get :show, params: { code: 0 }
        expect(assigns(:code)).to eq("0")
      end

      it "renders the show template" do
        get :show, params: { code: 0 }
        expect(response).to render_template(:show)
      end
    end

    context "when code parameter is nil explicitly" do
      it "assigns @code to default 500" do
        get :show, params: { code: nil }
        expect(assigns(:code)).to eq(500)
      end

      it "renders the show template" do
        get :show, params: { code: nil }
        expect(response).to render_template(:show)
      end
    end

    context "when code parameter is an empty string" do
      it "assigns @code to empty string (falsy)" do
        get :show, params: { code: "" }
        expect(assigns(:code)).to eq(500)
      end

      it "renders the show template" do
        get :show, params: { code: "" }
        expect(response).to render_template(:show)
      end
    end
  end
end
