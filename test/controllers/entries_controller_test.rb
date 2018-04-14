require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  test 'entries index should render correctly' do
    get :index
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_template layout: 'layouts/application'
    assert_template :index
    assert_select '.entry-list' do
      assert_select '.entry-list__item', 2
    end
  end

  test "should generate index json" do
    get :index, params: { format: 'json' }
    assert_template :index
    assert_response :success
  end

  test "should generate sitemap" do
    get :sitemap, params: { format: 'xml', page: 1 }
    assert_template :sitemap
    assert_response :success
  end

  test "should generate sitemap index" do
    get :sitemap_index, params: { format: 'xml' }
    assert_template :sitemap_index
    assert_response :success
  end

  test "should generate atom feed" do
    get :feed, params: { format: 'atom' }
    assert_template :feed
    assert_response :success
  end

  test "should generate json feed" do
    get :feed, params: { format: 'json' }
    assert_template :feed
    assert_response :success
  end

  test 'photo page should render correctly' do
    entry = entries(:peppers)
    get :show, params: { year: entry.published_at.strftime('%Y'), month: entry.published_at.strftime('%-m'), day: entry.published_at.strftime('%-d'), id: entry.id, slug: entry.slug }
    assert_response :success
    assert_not_nil assigns(:entry)
    assert_template layout: 'layouts/application'
    assert_template :show
    assert_select '.entry', 1
    assert_select '.entry__photo', 1
    assert_select '.entry__figure', 1
    assert_select '.entry__headline', 1
  end

  test 'should preview page' do
    panda = entries(:panda)
    get :preview, params: { preview_hash: panda.preview_hash }
    assert_response :success
    assert_template :show
  end

  test 'should redirect published photos from preview page' do
    entry = entries(:peppers)
    get :preview, params: { preview_hash: entry.preview_hash }
    assert_redirected_to entry.permalink_url
  end

  test 'should redirect from tumblr url' do
    get :tumblr, params: { tumblr_id: '17444976847' }
    entry = entries(:peppers)
    assert_not_nil assigns(:entry)
    assert_equal assigns(:entry), entry
    assert_redirected_to entry.permalink_url
  end

  test 'should redirect from photo url' do
    photo = photos(:peppers)
    entry = entries(:peppers)
    get :photo, params: { id: photo.id }
    assert_redirected_to entry.permalink_url
  end

  test 'should render tag page' do
    entry = entries(:peppers)
    entry.tag_list = 'washington'
    entry.save
    get :tagged, params: { tag: 'washington' }
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_template layout: 'layouts/application'
    assert_template :tagged
    assert_select '.entry-list' do
      assert_select '.entry-list__item', 1
    end
  end

  test 'should render tag page json' do
    entry = entries(:peppers)
    entry.tag_list = 'washington'
    entry.save
    get :tagged, params: { tag: 'washington', format: 'json' }
    assert_template :tagged
    assert_response :success
  end

  test 'should render tag atom feed' do
    entry = entries(:peppers)
    entry.tag_list = 'washington'
    entry.save
    get :tag_feed, params: { tag: 'washington', format: 'atom' }
    assert_template :tag_feed
    assert_response :success
  end

  test 'should render tag json feed' do
    entry = entries(:peppers)
    entry.tag_list = 'washington'
    entry.save
    get :tag_feed, params: { tag: 'washington', format: 'json' }
    assert_template :tag_feed
    assert_response :success
  end
end
