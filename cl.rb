# cl.rb # Contact List App

require 'sinatra'
require 'tilt/erubis'
require 'securerandom'
require 'yaml'
require 'pry'

require_relative "session_persistence"

configure do
  enable :sessions # Enabling session support for Sinatra app.
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload "session_persistence.rb"
end

helpers do
  def data_path
    if ENV['RACK_ENV'] == 'test'
      File.expand_path('../test/data/contacts.yml', __FILE__)
    else
      File.expand_path('../data/contacts.yml', __FILE__)
    end
  end

  def display_order(contacts, order)
    first_letter = order.nil? ? '' : order.downcase[0]
    case first_letter
    when 'c'
      session[:message] = 'Sorting by category.'
      contacts.sort_by { |contact| contact[:category] }
    when 'e'
      session[:message] = 'Sorting by email.'
      contacts.sort_by { |contact| contact[:email] }
    else
      session[:message] = 'Sorting by name.'
      contacts.sort_by { |contact| contact[:name] }
    end
  end
end

before do
  @storage = SessionPersistence.new(session)
end

# after do
#   @storage.disconnect
# end

# Routes #

# Home page
get '/' do
  @contacts = @storage.get_contacts
  if params[:sort]
    @contacts = display_order(@contacts, params[:sort])
  end
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
  contacts = YAML.load_file(data_path)

  @name = params[:contact]
  @info = contacts[@name]
  erb :details
end
