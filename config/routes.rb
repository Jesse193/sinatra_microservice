namespace '/api' do
  get '/protected_data' do
    protected!
    json(message: "This is protected data accessible only to authenticated users.")
  end
end