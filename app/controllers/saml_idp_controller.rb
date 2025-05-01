class SamlIdpController < ApplicationController
  include SamlIdp::Controller
  include OidcClient

  def show
    render xml: SamlIdp.metadata.signed
  end

  def new
    validate_saml_request or return
    session[:state] = SecureRandom.hex
    session[:SAMLRequest] = params[:SAMLRequest]
    session[:RelayState] = params[:RelayState]
    redirect_to oidc_client.authorization_uri(state: session[:state]), allow_other_host: true
  end

  def create
    validate_saml_request(session[:SAMLRequest]) or return
    if session[:state] != params[:state]
      Rails.logger.error "Mismatched state! #{session[:state]} <> #{params[:state]}"
      head :forbidden and return
    end
    oidc_client.authorization_code = params[:code]
    user = User.from_token(oidc_client.access_token!)
    if user.nil?
      head :forbidden and return
    else
      Rails.logger.info "Authenticated user: #{user.user_id}"
      @saml_response = encode_response(user)
    end
  end
end
