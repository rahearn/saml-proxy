class SamlIdpController < ApplicationController
  include SamlIdp::Controller
  include OidcClient

  protect_from_forgery

  before_action :validate_saml_request, only: [:new, :create]

  def show
    render xml: SamlIdp.metadata.signed
  end

  def new
    session[:state] = SecureRandom.hex
    session[:SAMLRequest] = params[:SAMLRequest]
    session[:RelayState] = params[:RelayState]
    redirect_to oidc_client.authorization_uri(state: session[:state]), allow_other_host: true
  end

  def create
    fail "Mismatched state! #{session[:state]} <> #{params[:state]}" unless session[:state] == params[:state]
    user = User.from_token(params[:token])
    if user.nil?
      head :forbidden and return
    else
      @saml_response = idp_make_saml_response(user)
    end
  end

  private def idp_make_saml_response(user)
    encode_response user
  end
end
