require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
	@user = users(:serewka)
  end

  test "login with invalid information" do
	get login_path #переход на страницу login
	assert_template 'sessions/new' #страница отображается
	post login_path, params: {session: { email: "", password: "" }} #ввод данных для вызова ошибки
	assert_template 'sessions/new' #страница отображается
	assert_not flash.empty? #выводится предупреждение о ошибке
	get root_path #переход на главную страницу
	assert flash.empty? #выводится предупреждение о ошибке
  end

  test "login with valid information followed by logout" do
	get login_path
	post login_path, params: { session: { email: @user.email, password: 'example' } }
	assert is_logged_in?
	assert_redirected_to @user
	follow_redirect!
	assert_template 'users/show'
	assert_select "a[href=?]", login_path, count: 0
	assert_select "a[href=?]", logout_path
	assert_select "a[href=?]", user_path(@user)
	delete logout_path
	assert_not is_logged_in?
	assert_redirected_to root_url
	# имитация щелчка для выхода во втором окне
	delete logout_path
	follow_redirect!
	assert_select "a[href=?]", login_path
	assert_select "a[href=?]", logout_path, count: 0
	assert_select "a[href=?]", user_path(@user), count: 0
  	end 
	
	test "login with remembering" do
	  log_in_as(@user, remember_me: '1')
	  assert_equal assigns(:user).remember_token, cookies['remember_token']
	  assert_not_empty cookies['remember_token']
	end

	test "login without remembering" do
	  log_in_as(@user, remember_me: '0')
	  assert_nil cookies['remember_token']
	end

end
