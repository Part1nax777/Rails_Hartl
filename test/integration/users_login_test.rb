require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test "login with invalid information" do
	get login_path #переход на страницу login
	assert_template 'sessions/new' #страница отображается
	post login_path, params: {session: { email: "", password: "" }} #ввод данных для вызова ошибки
	assert_template 'sessions/new' #страница отображается
	assert_not flash.empty? #выводится предупреждение о ошибке
	get root_path #переход на главную страницу
	assert flash.empty? #выводится предупреждение о ошибке
  end
end
