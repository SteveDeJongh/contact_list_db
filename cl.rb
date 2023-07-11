# cl.rb # Contact List App

require 'sinatra'
require 'tilt/erubis'
require 'securerandom'
require 'yaml'
require 'pry'

require_relative 'database_persistence'

configure do
  enable :sessions # Enabling session support for Sinatra app.
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistence.rb'
end

helpers do
  def data_path
    # if ENV['RACK_ENV'] == 'test'
    # else
    # end
  end

  def display_order(order)
    first_letter = order.nil? ? '' : order.downcase[0]
    case first_letter
    when 'c'
      session[:message] = 'Sorting by category.'
      session[:sort_order] = 'category'
      # contacts.sort_by { |contact| contact[:category].downcase }
    when 'e'
      session[:message] = 'Sorting by email.'
      session[:sort_order] = 'email'
      # contacts.sort_by { |contact| contact[:email].downcase }
    else
      session[:message] = 'Sorting by name.'
      session[:sort_order] = 'name'
      # contacts.sort_by { |contact| contact[:name].downcase }
    end
  end
end

before do
  @storage = Databasepersistence.new
end

after do
  @storage.disconnect
end

# Routes #

# Home page
get '/' do
  if params[:sort]
    display_order(params[:sort])
  elsif session[:sort_order].nil?
    session[:sort_order] = 'name'
  end
  @contacts = @storage.contacts(session[:sort_order])
  erb :index
end

# Add Contact page
get '/addcontact' do
  erb :addcontact
end

# Add a contact
post '/addcontact' do
  data = { name: params[:name], phone: params[:phonenumber], email: params[:email], category: params[:category] }

  if @storage.exists?(data[:name])
    session[:message] = 'Contact already exists.'
    erb :addcontact
  else
    session[:message] = 'Contact created successfully.'
    @storage.add_contact(data)
    redirect '/'
  end
end

# Delete a Contact
post '/:contact/delete' do
  name = params[:contact]

  if @storage.exists?(name)
    session[:message] = "#{name} deleted."
    @storage.delete_contact(name)
    redirect '/'
  else
    session[:message] = "#{name} does not exist."
    erb :index
  end
end

# Detailed information page for a Contact
get '/:contact/details' do
  @name = params[:contact]
  @info = @storage.contact_details(@name)
  erb :details
end
