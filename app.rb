#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

def is_barber_exists? db, name
  db.execute('select * from barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'Insert Into Barbers (name) Values (?)', [barber]
    end
  end
end

before do
  db = get_db
  @barbers =  db.execute 'select * from Barbers'
end

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS
  "Users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "username" TEXT,
    "phone" TEXT,
    "datestamp" TEXT,
    "barber" TEXT,
    "color", TEXT
  )'
  db.execute 'CREATE TABLE IF NOT EXISTS
  "Barbers" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT
  )'

  seed_db db, ['Walter White', 'Jessie Pinkman', 'Gus Fring', 'Mike Couper']
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

get '/feedback' do
  erb :feedback
end

get '/contacts' do
  erb :contacts
end

get '/entry' do
  erb :entry
end

get '/admin' do
  db = get_db
  @results =  db.execute 'select * from Users order by id desc'
  erb :admin
end

post '/visit' do
  @user_name = params[:user_name]
  @phone = params[:phone]
  @date_time = params[:date_time]
  @barber = params[:barber]
  @color = params[:color]

  if @user_name == '' or @phone == '' or @date_time == ''
    @error = 'Не все поля заполнены'
    erb :visit
  else

    db = get_db
    db.execute 'insert into Users (username, phone, datestamp, barber, color)
                values (?, ?, ?, ?, ?)', [@user_name, @phone, @date_time, @barber, @color]

    ebr "Спасибо, #{@user_name}. Вы записаны на #{@date_time} к парикмахеру #{@barber}"

  end
end

post '/feedback' do
  @email = params[:email]
  @mes = params[:mes]

  if @email == '' or @mes == ''
    @error = 'Не все поля заполнены'
    erb :feedback
  else

    @fil = File.open("./public/message.txt", "a")
    @fil.write "Email: #{@email}, message: #{@mes}\n"
    @fil.close

    erb "Спасибо за сообщение!"

  end
end

post '/entry' do
  @login = params[:login]
  @password = params[:password]

  if @login == 'admin' && @password == 'admin'
    redirect '/admin'
  else
    erb "Access denied"
  end
end
