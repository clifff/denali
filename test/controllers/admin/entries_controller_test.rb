require 'test_helper'

class Admin::EntriesControllerTest < ActionController::TestCase

  def setup
    session[:user_id] = users(:guille).id
    @blog = blogs(:allencompassingtrip)
    @entry = entries(:peppers)
    @entry.tag_list = 'Washington'
    @entry.save
    super
  end

  test 'should render entries page' do
    get :index
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :index
  end

  test 'should render queued page' do
    get :queued
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :queued
  end

  test 'should render drafts page' do
    get :drafts
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :drafts
  end

  test 'should render tag page' do
    get :tagged, params: { tag: 'washington' }
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_template layout: 'layouts/admin'
    assert_template :tagged
  end

  test 'should render entry page' do
    get :show, params: { id: @entry.id }
    assert_not_nil assigns(:entry)
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :show
  end

  test 'should render new entry page' do
    get :new
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :new
  end

  test 'should render edit entry page' do
    get :edit, params: { id: @entry.id }
    assert_not_nil assigns(:entry)
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :edit
  end

  test 'should render share entry page' do
    get :share, params: { id: @entry.id }
    assert_not_nil assigns(:entry)
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :share
  end

  test 'should render crops page' do
    get :crops, params: { id: @entry.id }
    assert_not_nil assigns(:entry)
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :crops
  end

  test 'should render photo fields' do
    get :photo
    assert_response :success
    assert_template layout: nil
    assert_template :photo
  end

  test 'should queue entries' do
    entry = entries(:franklin)
    patch :queue, params: { id: entry.id }
    assert assigns(:entry).is_queued?
    assert_not_nil assigns(:entry).position
  end

  test 'should draft entries' do
    entry = entries(:franklin)
    patch :draft, params: { id: entry.id }
    assert assigns(:entry).is_draft?
    assert_nil assigns(:entry).position
  end

  test 'should publish entries' do
    entry = entries(:franklin)
    patch :publish, params: { id: entry.id }
    assert assigns(:entry).is_published?
    assert_nil assigns(:entry).position
  end

  test 'should create entries' do
    post :create, params: { entry: { title: 'Published', status: 'published' } }
    assert assigns(:entry).is_published?
    assert_nil assigns(:entry).position
    assert_redirected_to new_admin_entry_path

    post :create, params: { entry: { title: 'Draft', status: 'draft' } }
    assert assigns(:entry).is_draft?
    assert_nil assigns(:entry).position
    assert_redirected_to new_admin_entry_path

    post :create, params: { entry: { title: 'Queued', status: 'queued' } }
    assert assigns(:entry).is_queued?
    assert_not_nil assigns(:entry).position
    assert_redirected_to new_admin_entry_path
  end

  test 'should update entries' do
    entry = entries(:peppers)
    patch :update, params: { id: entry.id, entry: { id: entry.id } }
    assert_redirected_to admin_entry_path(entry)
  end

  test 'update should change modified_at' do
    entry = entries(:peppers)
    modified = entry.modified_at
    patch :update, params: { id: entry.id, entry: { id: entry.id } }
    entry.reload
    assert_not_equal modified, entry.modified_at
  end

  test 'should render organize queue page' do
    get :organize_queue
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :organize_queue
  end

  test 'should properly sort queue' do
    blog = blogs(:allencompassingtrip)
    user = users(:guille)

    entry1 = entries(:panda)
    assert_equal entry1.position, 1

    entry2 = Entry.new(title: 'Title 1', status: 'queued', blog: blog, user: user)
    entry2.save
    assert_equal entry2.position, 2

    entry3 = Entry.new(title: 'Title 2', status: 'queued', blog: blog, user: user)
    entry3.save
    assert_equal entry3.position, 3

    entry4 = Entry.new(title: 'Title 3', status: 'queued', blog: blog, user: user)
    entry4.save
    assert_equal entry4.position, 4

    ids = [entry4.id, entry3.id, entry2.id, entry1.id]
    post :update_queue, params: { entry_ids: ids }, format: 'json'

    assert_response :success

    entry1.reload
    entry2.reload
    entry3.reload
    entry4.reload

    assert_equal entry4.position, 1
    assert_equal entry3.position, 2
    assert_equal entry2.position, 3
    assert_equal entry1.position, 4
  end
end
