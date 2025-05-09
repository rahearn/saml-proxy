class SamlIdpController < ApplicationController
  include SamlIdp::Controller
  include OidcClient

  def show
    render xml: SamlIdp.metadata.signed
  end

  def new
    if validate_saml_request
      reset_session
      session[:state] = SecureRandom.hex
      session[:SAMLRequest] = params[:SAMLRequest]
      session[:Signature] = params[:Signature]
      session[:SigAlg] = params[:SigAlg]
      session[:RelayState] = params[:RelayState]
      redirect_to oidc_client.authorization_uri(state: session[:state]), allow_other_host: true
    else
      Rails.logger.error "Could not validate SAML request: #{saml_request.errors.join(", ")}"
      render :forbidden, status: :forbidden
    end
  end

  def create
    decode_request(session[:SAMLRequest], session[:Signature], session[:SigAlg], session[:RelayState])
    if session[:state] == params[:state] && valid_saml_request?
      oidc_client.authorization_code = params[:code]
      user = User.from_token(oidc_client.access_token!)
      if user.nil?
        Rails.logger.error "Could not decode JWT"
        render :forbidden, status: :forbidden
      else
        Rails.logger.info "Authenticated user: #{user.user_id}"
        @relay_state = session[:RelayState]
        @saml_response = encode_response(user, encode_opts)
      end
    else
      Rails.logger.error "Could not validate SAML request: #{saml_request.errors.join(", ")}"
      render :forbidden, status: :forbidden
    end
    reset_session
  end

  private

  def encode_opts
    opts = {
      signed_message: true
    }
    if encryption_cert.present?
      opts[:encryption] = {
        cert: encryption_cert,
        block_encryption: "aes256-cbc",
        key_transport: "rsa-oaep-mgf1p"
      }
    end
    opts
  end

  def encryption_cert
    @encryption_cert ||= begin
      sp = saml_request.service_provider
      cert = sp.current_metadata&.encryption_certificate
      cert.present? ? cert : sp.cert
    end
  end
end
