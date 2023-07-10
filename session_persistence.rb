class SessionPersistence

  def initialize(session)
    @session = session
    @session[:contacts] ||= []
  end

  def logged_in?
    @session.key?(:username)
  end

  def exists?(name)
    @session[:contacts].any? { |contact| contact[:name] == name }
  end

  def add_contact(new_contact)
    @session[:contacts] << new_contact
  end

  def get_contacts
    @session[:contacts]
  end

  def delete_contact(name)
    @session[:contacts].delete_if { |contact| contact[:name] == name}
  end

end