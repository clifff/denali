require 'test_helper'

class Admin::EntriesControllerTest < ActionController::TestCase

  def setup
    session[:user_id] = users(:guille).id
    @entry = entries(:peppers)
    @entry.tag_list = 'washington'
    @entry.save
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

  test 'should render imported page' do
    get :imported
    assert_response :success
    assert_template layout: 'layouts/admin'
    assert_template :imported
  end

  test 'should render tag page' do
    get :tagged, params: { tag: 'washington' }
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_template layout: 'layouts/admin'
    assert_template :tagged
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
    assert_redirected_to queued_admin_entries_path
  end

  test 'should draft entries' do
    entry = entries(:franklin)
    patch :draft, params: { id: entry.id }
    assert assigns(:entry).is_draft?
    assert_nil assigns(:entry).position
    assert_redirected_to drafts_admin_entries_path
  end

  test 'should publish entries' do
    entry = entries(:franklin)
    patch :publish, params: { id: entry.id }
    assert assigns(:entry).is_published?
    assert_nil assigns(:entry).position
    assert_redirected_to assigns(:entry).permalink_url
  end

  test 'should create entries' do
    post :create, params: { entry: { title: 'Published', status: 'published' } }
    assert assigns(:entry).is_published?
    assert_nil assigns(:entry).position
    assert_redirected_to assigns(:entry).permalink_url

    post :create, params: { entry: { title: 'Draft', status: 'draft' } }
    assert assigns(:entry).is_draft?
    assert_nil assigns(:entry).position
    assert_redirected_to drafts_admin_entries_path

    post :create, params: { entry: { title: 'Queued', status: 'queued' } }
    assert assigns(:entry).is_queued?
    assert_not_nil assigns(:entry).position
    assert_redirected_to queued_admin_entries_path
  end

  test 'should update entries' do
    entry = entries(:peppers)
    patch :update, params: { id: entry.id, entry: { id: entry.id } }
    assert_redirected_to assigns(:entry).permalink_url
  end

  test 'should reposition entries' do
    blog = blogs(:allencompassingtrip)
    test_1 = Entry.new(title: 'test 1', status: 'queued', blog_id: blog.id)
    test_1.save
    test_2 = Entry.new(title: 'test 2', status: 'queued', blog_id: blog.id)
    test_2.save

    entry = entries(:panda)

    post :down, params: { id: entry.id }
    assert_equal assigns(:entry).position, 2
    assert_redirected_to queued_admin_entries_path

    post :up, params: { id: entry.id }
    assert_equal assigns(:entry).position, 1
    assert_redirected_to queued_admin_entries_path

    post :bottom, params: { id: entry.id }
    assert_equal assigns(:entry).position, 3
    assert_redirected_to queued_admin_entries_path

    post :top, params: { id: entry.id }
    assert_equal assigns(:entry).position, 1
    assert_redirected_to queued_admin_entries_path
  end
end
