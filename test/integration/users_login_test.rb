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

  test "login with valid information" do
	get login_path
	post login_path, params: { session: { email: @user.email, password: 'password' } }
	assert_redirected_to @user
	follow_redirect!
	assert_template 'users/show'
	assert_select "a[href=?]", login_path, count: 0
	assert_select "a[href=?]", logout_path
	assert_select "a[href=?]", user_path(@user)
  end

end
