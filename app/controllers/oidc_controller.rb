class OidcController < ApplicationController
  include OidcClient

  def callback
    fail "Mismatched state! #{session[:state]} <> #{params[:state]}" unless session[:state] == params[:state]
    oidc_client.authorization_code = params[:code]
    @token = oidc_client.access_token!.id_token
  end
end
