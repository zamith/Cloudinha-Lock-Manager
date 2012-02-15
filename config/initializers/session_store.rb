# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_requests_session',
  :secret      => '5057e712e89774d9f7fc48d9ce406405f4d3a3563e7f872fdb4c0f06b3ef6d882ee9137040c5ee8e2c4304fc653e971a6309fbad861182776000762f87dea5a2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
