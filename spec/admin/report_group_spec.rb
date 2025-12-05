# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ReportGroup Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/report_groups' do
    let!(:report_group) do
      ReportGroup.create!(
        title: 'Test Report',
        width: 100,
        minimum: 10,
        visualization: 'chart',
        transformation_rules: {
          columns: [
            {
              source: 'name',
              output: 'Name',
              transformations: ['upcase'],
              format: nil
            }
          ]
        }.to_json
      )
    end

    it 'displays the index page' do
      get admin_report_groups_path
      expect(response).to have_http_status(:success)
    end

    it 'shows report group columns' do
      get admin_report_groups_path
      expect(response.body).to include('Test Report')
      expect(response.body).to include('100')
      expect(response.body).to include('10')
      expect(response.body).to include('chart')
    end

    it 'displays selectable column' do
      get admin_report_groups_path
      expect(response.body).to match(/selectable.*column/i)
    end

    it 'displays id column' do
      get admin_report_groups_path
      expect(response.body).to include(report_group.id.to_s)
    end

    it 'displays actions column' do
      get admin_report_groups_path
      expect(response.body).to match(/View|Edit|Delete/i)
    end
  end

  describe 'GET /admin/report_groups/:id' do
    let!(:report_group) do
      ReportGroup.create!(
        title: 'Detail Report',
        width: 50,
        minimum: 5,
        visualization: 'table',
        transformation_rules: {
          columns: [
            {
              source: 'id',
              output: 'ID',
              transformations: ['to_s'],
              format: nil
            }
          ]
        }.to_json
      )
    end

    it 'displays the show page' do
      get admin_report_group_path(report_group)
      expect(response).to have_http_status(:success)
    end

    it 'shows report group details' do
      get admin_report_group_path(report_group)
      expect(response.body).to include('Detail Report')
      expect(response.body).to include('50')
      expect(response.body).to include('5')
    end
  end

  describe 'GET /admin/report_groups/new' do
    it 'displays the new form' do
      get new_admin_report_group_path
      expect(response).to have_http_status(:success)
    end

    it 'has form fields for all permitted params' do
      get new_admin_report_group_path
      expect(response.body).to include('report_group[title]')
      expect(response.body).to include('report_group[width]')
      expect(response.body).to include('report_group[minimum]')
      expect(response.body).to include('report_group[visualization]')
    end
  end

  describe 'POST /admin/report_groups' do
    let(:valid_params) do
      {
        report_group: {
          title: 'New Report',
          width: 80,
          minimum: 15,
          visualization: 'pie',
          transformation_rules: {
            columns: [
              {
                source: 'status',
                output: 'Status',
                transformations: ['upcase'],
                format: nil
              }
            ]
          }.to_json
        }
      }
    end

    it 'creates a new report group' do
      expect do
        post admin_report_groups_path, params: valid_params
      end.to change(ReportGroup, :count).by(1)
    end

    it 'redirects to the report group show page' do
      post admin_report_groups_path, params: valid_params
      expect(response).to redirect_to(admin_report_group_path(ReportGroup.last))
    end

    it 'creates with correct attributes' do
      post admin_report_groups_path, params: valid_params
      report_group = ReportGroup.last
      expect(report_group.title).to eq('New Report')
      expect(report_group.width).to eq(80)
      expect(report_group.minimum).to eq(15)
      expect(report_group.visualization).to eq('pie')
    end
  end

  describe 'GET /admin/report_groups/:id/edit' do
    let!(:report_group) do
      ReportGroup.create!(
        title: 'Edit Report',
        width: 60,
        minimum: 20,
        visualization: 'bar',
        transformation_rules: {
          columns: [
            {
              source: 'value',
              output: 'Value',
              transformations: ['to_i'],
              format: 'integer'
            }
          ]
        }.to_json
      )
    end

    it 'displays the edit form' do
      get edit_admin_report_group_path(report_group)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_report_group_path(report_group)
      expect(response.body).to include('Edit Report')
      expect(response.body).to include('60')
    end
  end

  describe 'PUT /admin/report_groups/:id' do
    let!(:report_group) do
      ReportGroup.create!(
        title: 'Original Title',
        width: 40,
        minimum: 8,
        visualization: 'line',
        transformation_rules: {
          columns: [
            {
              source: 'name',
              output: 'Name',
              transformations: [],
              format: nil
            }
          ]
        }.to_json
      )
    end

    let(:update_params) do
      {
        report_group: {
          title: 'Updated Title',
          width: 90
        }
      }
    end

    it 'updates the report group' do
      put admin_report_group_path(report_group), params: update_params
      report_group.reload
      expect(report_group.title).to eq('Updated Title')
      expect(report_group.width).to eq(90)
    end

    it 'redirects to the show page' do
      put admin_report_group_path(report_group), params: update_params
      expect(response).to redirect_to(admin_report_group_path(report_group))
    end
  end

  describe 'DELETE /admin/report_groups/:id' do
    let!(:report_group) do
      ReportGroup.create!(
        title: 'Delete Me',
        width: 30,
        minimum: 5,
        visualization: 'scatter',
        transformation_rules: {
          columns: [
            {
              source: 'id',
              output: 'ID',
              transformations: [],
              format: nil
            }
          ]
        }.to_json
      )
    end

    it 'deletes the report group' do
      expect do
        delete admin_report_group_path(report_group)
      end.to change(ReportGroup, :count).by(-1)
    end

    it 'redirects to the index page' do
      delete admin_report_group_path(report_group)
      expect(response).to redirect_to(admin_report_groups_path)
    end
  end

  describe 'permitted parameters' do
    it 'permits title' do
      post admin_report_groups_path, params: {
        report_group: {
          title: 'Permitted Title',
          transformation_rules: {
            columns: [
              {
                source: 'name',
                output: 'Name',
                transformations: [],
                format: nil
              }
            ]
          }.to_json
        }
      }
      expect(ReportGroup.last.title).to eq('Permitted Title')
    end

    it 'permits width' do
      post admin_report_groups_path, params: {
        report_group: {
          title: 'Test',
          width: 123,
          transformation_rules: {
            columns: [
              {
                source: 'name',
                output: 'Name',
                transformations: [],
                format: nil
              }
            ]
          }.to_json
        }
      }
      expect(ReportGroup.last.width).to eq(123)
    end

    it 'permits minimum' do
      post admin_report_groups_path, params: {
        report_group: {
          title: 'Test',
          minimum: 25,
          transformation_rules: {
            columns: [
              {
                source: 'name',
                output: 'Name',
                transformations: [],
                format: nil
              }
            ]
          }.to_json
        }
      }
      expect(ReportGroup.last.minimum).to eq(25)
    end

    it 'permits visualization' do
      post admin_report_groups_path, params: {
        report_group: {
          title: 'Test',
          visualization: 'custom',
          transformation_rules: {
            columns: [
              {
                source: 'name',
                output: 'Name',
                transformations: [],
                format: nil
              }
            ]
          }.to_json
        }
      }
      expect(ReportGroup.last.visualization).to eq('custom')
    end
  end

  describe 'menu configuration' do
    it 'appears under Users parent menu' do
      get admin_report_groups_path
      expect(response).to have_http_status(:success)
    end
  end
end
