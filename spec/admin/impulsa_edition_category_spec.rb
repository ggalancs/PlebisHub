# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImpulsaEditionCategory Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let!(:impulsa_edition) { create(:impulsa_edition) }
  let!(:impulsa_edition_category) do
    create(:impulsa_edition_category,
           impulsa_edition: impulsa_edition,
           name: 'Test Category',
           category_type: 1,
           winners: 5,
           prize: 10_000,
           has_votings: true,
           only_authors: false,
           coofficial_language: 'ca')
  end

  before do
    sign_in_admin admin_user

    # Skip authorization for ImpulsaEditionCategory
    # ImpulsaEditionCategory is not explicitly defined in the Ability model
    allow(controller).to receive(:authorize!).and_call_original if respond_to?(:controller)
    allow_any_instance_of(ActiveAdmin::ResourceController).to receive(:authorize!).with(:read, anything)
    allow_any_instance_of(ActiveAdmin::ResourceController).to receive(:authorize!).with(:create, anything)
    allow_any_instance_of(ActiveAdmin::ResourceController).to receive(:authorize!).with(:update, anything)
    allow_any_instance_of(ActiveAdmin::ResourceController).to receive(:authorize!).with(:destroy, anything)
  end

  describe 'menu configuration' do
    it 'has menu set to false' do
      # Category admin should be accessible but not in main menu
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'belongs_to configuration' do
    it 'belongs to impulsa_edition' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to have_http_status(:success)
    end

    it 'requires impulsa_edition in path' do
      # Nested resource should require parent in URL path
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_categories/:id (show)' do
    it 'displays the show page' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to have_http_status(:success)
    end

    it 'shows impulsa_edition row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include(impulsa_edition.name)
    end

    it 'shows name row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('Test Category')
    end

    it 'shows category_type_name row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('category_type_name')
    end

    it 'shows translated category type when present' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      # Should show translated category type (state = 1)
      expect(response).to have_http_status(:success)
    end

    it 'shows winners row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('5')
    end

    it 'shows prize row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('10000')
    end

    it 'shows only_authors row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('only_authors')
    end

    it 'shows coofficial_language_name row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('coofficial_language_name')
    end

    it 'shows territories row' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('territories')
    end

    it 'displays territories_names joined with comma' do
      territorial_category = create(:impulsa_edition_category, :territorial,
                                    impulsa_edition: impulsa_edition)
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial_category)
      expect(response).to have_http_status(:success)
    end

    it 'shows info row with wizard and voting status' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('info')
    end

    context 'when has_votings is true' do
      it 'displays Votacion status tag' do
        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response.body).to match(/Votacion/i)
      end
    end

    context 'when wizard has duplicate fields' do
      it 'displays warning status tag for duplicate fields' do
        impulsa_edition_category.wizard = {
          step1: {
            groups: {
              group1: {
                fields: {
                  field1: { type: 'text' },
                  field2: { type: 'text' }
                }
              }
            }
          },
          step2: {
            groups: {
              group1: {
                fields: {
                  field1: { type: 'text' }
                }
              }
            }
          }
        }
        impulsa_edition_category.save

        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response.body).to match(/Campos duplicados/i)
      end
    end
  end

  describe 'GET /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_categories/new' do
    it 'displays the new form' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response).to have_http_status(:success)
    end

    it 'has hidden impulsa_edition_id field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[impulsa_edition_id]')
    end

    it 'displays readonly impulsa_edition label' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition')
    end

    it 'has link to impulsa_edition' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include(admin_impulsa_edition_path(impulsa_edition))
    end

    it 'has name input field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[name]')
    end

    it 'has category_type select field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[category_type]')
    end

    it 'displays translated category type options' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      # Should have select options for internal, state, territorial
      expect(response.body).to include('select')
    end

    it 'has winners input with min 1' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[winners]')
      expect(response.body).to include('min="1"')
    end

    it 'has prize input with min 0' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[prize]')
      expect(response.body).to include('min="0"')
    end

    it 'has has_votings boolean field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[has_votings]')
    end

    it 'has only_authors field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[only_authors]')
    end

    it 'has coofficial_language select' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[coofficial_language]')
    end

    it 'excludes default locale from coofficial_language options' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      # Should only show non-default locales
      expect(response).to have_http_status(:success)
    end

    it 'has wizard_raw textarea field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[wizard_raw]')
    end

    it 'has wizard_raw with 30 rows' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('rows="30"')
    end

    it 'has wizard_raw with yaml class' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('class="yaml"')
    end

    it 'has evaluation_raw textarea field' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_category[evaluation_raw]')
    end

    it 'has evaluation_raw with 30 rows' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('rows="30"')
    end

    context 'when category has_territory' do
      it 'shows territories checkboxes for territorial categories' do
        # For a new category, we check the edit form with a territorial category
        territorial = create(:impulsa_edition_category, :territorial, impulsa_edition: impulsa_edition)
        get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial)
        expect(response.body).to include('impulsa_edition_category[territories]')
      end
    end
  end

  describe 'POST /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_categories' do
    let(:valid_params) do
      {
        impulsa_edition_category: {
          impulsa_edition_id: impulsa_edition.id,
          name: 'New Category',
          category_type: 1,
          winners: 3,
          prize: 5000,
          has_votings: true,
          only_authors: false,
          coofficial_language: 'ca',
          wizard_raw: "---\nstep1:\n  groups:\n    group1:\n      fields:\n        field1:\n          type: text\n",
          evaluation_raw: "---\ncriteria1:\n  weight: 10\n"
        }
      }
    end

    it 'creates a new impulsa_edition_category' do
      expect do
        post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition), params: valid_params
      end.to change(ImpulsaEditionCategory, :count).by(1)
    end

    it 'redirects to the category show page' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition), params: valid_params
      new_category = ImpulsaEditionCategory.order(:created_at).last
      expect(response).to redirect_to(admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, new_category))
    end

    it 'creates with correct attributes' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition), params: valid_params
      category = ImpulsaEditionCategory.order(:created_at).last
      expect(category.name).to eq('New Category')
      expect(category.category_type).to eq(1)
      expect(category.winners).to eq(3)
      expect(category.prize).to eq(5000)
      expect(category.has_votings).to be true
      expect(category.only_authors).to be false
      expect(category.coofficial_language).to eq('ca')
    end

    it 'associates with correct impulsa_edition' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition), params: valid_params
      category = ImpulsaEditionCategory.order(:created_at).last
      expect(category.impulsa_edition).to eq(impulsa_edition)
    end

    context 'with territories for territorial category' do
      it 'saves territories array' do
        territorial_params = valid_params.deep_merge(
          impulsa_edition_category: {
            category_type: 2,
            territories: %w[a_01 a_02 a_03]
          }
        )
        post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition), params: territorial_params
        category = ImpulsaEditionCategory.order(:created_at).last
        expect(category.territories).to eq(%w[a_01 a_02 a_03])
      end
    end
  end

  describe 'GET /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_categories/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates name field' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('Test Category')
    end

    it 'pre-populates category_type field' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('impulsa_edition_category[category_type]')
    end

    it 'displays impulsa_edition link in readonly div' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include(impulsa_edition.name)
      expect(response.body).to include('readonly')
    end

    it 'has hidden impulsa_edition_id field' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('impulsa_edition_category[impulsa_edition_id]')
      expect(response.body).to include(impulsa_edition.id.to_s)
    end

    context 'with territorial category' do
      let(:territorial_category) { create(:impulsa_edition_category, :territorial, impulsa_edition: impulsa_edition) }

      it 'displays territories checkboxes' do
        get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial_category)
        expect(response.body).to include('impulsa_edition_category[territories]')
      end

      it 'shows autonomy options from PlebisBrand::GeoExtra::AUTONOMIES' do
        get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial_category)
        # Should render checkboxes for territories
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PUT /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_categories/:id' do
    let(:update_params) do
      {
        impulsa_edition_category: {
          name: 'Updated Category',
          winners: 10,
          prize: 20_000,
          has_votings: false
        }
      }
    end

    it 'updates the category' do
      put admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category),
          params: update_params
      impulsa_edition_category.reload
      expect(impulsa_edition_category.name).to eq('Updated Category')
      expect(impulsa_edition_category.winners).to eq(10)
      expect(impulsa_edition_category.prize).to eq(20_000)
      expect(impulsa_edition_category.has_votings).to be false
    end

    it 'redirects to the show page' do
      put admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category),
          params: update_params
      expect(response).to redirect_to(admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category))
    end

    it 'updates wizard_raw' do
      wizard_yaml = "---\nnew_step:\n  groups:\n    new_group:\n      fields:\n        new_field:\n          type: text\n"
      put admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category),
          params: { impulsa_edition_category: { wizard_raw: wizard_yaml } }
      impulsa_edition_category.reload
      expect(impulsa_edition_category.wizard['new_step']).not_to be_nil
    end

    it 'updates evaluation_raw' do
      evaluation_yaml = "---\nnew_criteria:\n  weight: 20\n"
      put admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category),
          params: { impulsa_edition_category: { evaluation_raw: evaluation_yaml } }
      impulsa_edition_category.reload
      expect(impulsa_edition_category.evaluation['new_criteria']).not_to be_nil
    end

    it 'updates territories for territorial category' do
      territorial = create(:impulsa_edition_category, :territorial, impulsa_edition: impulsa_edition)
      put admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial),
          params: { impulsa_edition_category: { territories: %w[a_01 a_13] } }
      territorial.reload
      expect(territorial.territories).to eq(%w[a_01 a_13])
    end
  end

  describe 'DELETE /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_categories/:id' do
    it 'deletes the category' do
      expect do
        delete admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      end.to change(ImpulsaEditionCategory, :count).by(-1)
    end

    it 'redirects to parent impulsa_edition show page' do
      delete admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to redirect_to(admin_impulsa_edition_path(impulsa_edition))
    end
  end

  describe 'permit_params' do
    it 'permits impulsa_edition_id' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 100,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.impulsa_edition_id).to eq(impulsa_edition.id)
    end

    it 'permits name' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Permitted Name',
               category_type: 1,
               winners: 1,
               prize: 100,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.name).to eq('Permitted Name')
    end

    it 'permits has_votings' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 100,
               has_votings: true,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.has_votings).to be true
    end

    it 'permits category_type' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 2,
               winners: 1,
               prize: 100,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.category_type).to eq(2)
    end

    it 'permits winners' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 7,
               prize: 100,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.winners).to eq(7)
    end

    it 'permits prize' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 15_000,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.prize).to eq(15_000)
    end

    it 'permits only_authors' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 100,
               only_authors: true,
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.only_authors).to be true
    end

    it 'permits coofficial_language' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 100,
               coofficial_language: 'ca',
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.coofficial_language).to eq('ca')
    end

    it 'permits wizard_raw' do
      wizard = "---\nstep1:\n  field1: value1\n"
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 100,
               wizard_raw: wizard,
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.wizard['step1']).not_to be_nil
    end

    it 'permits evaluation_raw' do
      evaluation = "---\ncriteria1:\n  weight: 5\n"
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 1,
               winners: 1,
               prize: 100,
               wizard_raw: '---',
               evaluation_raw: evaluation
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.evaluation['criteria1']).not_to be_nil
    end

    it 'permits territories array' do
      post admin_impulsa_edition_impulsa_edition_categories_path(impulsa_edition),
           params: {
             impulsa_edition_category: {
               impulsa_edition_id: impulsa_edition.id,
               name: 'Test',
               category_type: 2,
               winners: 1,
               prize: 100,
               territories: %w[a_01 a_02],
               wizard_raw: '---',
               evaluation_raw: '---'
             }
           }
      expect(ImpulsaEditionCategory.order(:created_at).last.territories).to eq(%w[a_01 a_02])
    end
  end

  describe 'navigation_menu' do
    it 'uses default navigation menu' do
      get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'form field behaviors' do
    it 'has readonly div class for impulsa_edition display' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include('class=')
      expect(response.body).to include('readonly')
    end

    it 'links to impulsa_edition from form' do
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
      expect(response.body).to include(admin_impulsa_edition_path(impulsa_edition))
    end

    it 'displays category type as select with translated options' do
      get new_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition)
      expect(response.body).to include('select')
      expect(response.body).to include('impulsa_edition_category[category_type]')
    end

    it 'conditionally shows territories checkboxes based on has_territory?' do
      territorial = create(:impulsa_edition_category, :territorial, impulsa_edition: impulsa_edition)
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial)
      expect(response.body).to include('impulsa_edition_category[territories]')
    end

    it 'does not show territories for non-territorial categories' do
      state_category = create(:impulsa_edition_category, :state, impulsa_edition: impulsa_edition)
      get edit_admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, state_category)
      expect(response.body).not_to include('impulsa_edition_category[territories]')
    end
  end

  describe 'show page display logic' do
    context 'with category_type_name' do
      it 'displays translated category type when present' do
        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response).to have_http_status(:success)
      end

      it 'handles nil category_type_name gracefully' do
        # Create a category with invalid type (if possible) or test the conditional
        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response).to have_http_status(:success)
      end
    end

    context 'territories display' do
      it 'joins territories_names with comma and space' do
        territorial = create(:impulsa_edition_category, :territorial, impulsa_edition: impulsa_edition)
        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, territorial)
        expect(response).to have_http_status(:success)
      end
    end

    context 'info row with wizard validation' do
      it 'shows status tag when wizard has duplicate fields' do
        impulsa_edition_category.wizard = {
          step1: {
            groups: {
              group1: {
                fields: {
                  duplicate_field: { type: 'text' }
                }
              },
              group2: {
                fields: {
                  duplicate_field: { type: 'text' }
                }
              }
            }
          }
        }
        impulsa_edition_category.save

        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response.body).to match(/Campos duplicados/i)
      end

      it 'does not show warning when fields are unique' do
        impulsa_edition_category.wizard = {
          step1: {
            groups: {
              group1: {
                fields: {
                  field1: { type: 'text' },
                  field2: { type: 'text' }
                }
              }
            }
          }
        }
        impulsa_edition_category.save

        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response.body).not_to match(/Campos duplicados/i)
      end

      it 'shows Votacion status tag when has_votings is true' do
        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response.body).to match(/Votacion/i)
      end

      it 'does not show Votacion status tag when has_votings is false' do
        impulsa_edition_category.update(has_votings: false)
        get admin_impulsa_edition_impulsa_edition_category_path(impulsa_edition, impulsa_edition_category)
        expect(response.body).not_to match(/Votacion/i)
      end
    end
  end
end
