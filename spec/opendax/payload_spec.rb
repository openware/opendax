require 'opendax/payload'

describe Opendax::Payload do
  let(:secret) { 'myTailorIsRich42' }
  let(:encoder) { Opendax::Payload.new(secret: secret) }
  let(:valid_decoder) { encoder }
  let(:invalid_decoder) { Opendax::Payload.new(secret: 'randomSecret') }
  let(:service) { 'barong' }
  let(:image) { 'rubykube/barong:2.0.8-alpha' }
  let(:jwt) { encoder.generate!(service: service, image: image) }

  it 'should encode a JWT HMAC' do
    token = encoder.generate!(service: service, image: image)

    expect(token).not_to be_nil
    expect(token).to match /[A-Za-z0-9\-\._~\+\/]+=*/
  end

  it 'should decode a token with valid secret' do
    decoded = valid_decoder.safe_decode(jwt)

    expect(decoded).not_to be_nil
    expect(decoded['service']).to eq service
    expect(decoded['image']).to eq image
  end

  it 'should not decode a token with invalid secret' do
    decoded = invalid_decoder.safe_decode(jwt)

    expect(decoded).to be_nil
  end

  it 'defines an API' do
    pgen = Opendax::Payload.new(secret: '0x42', expire: 600)
    token = pgen.generate!(service: service, image: image)
    pgen.decode!(token)
    pgen.safe_decode(token)
  end

  it 'expire time should be configurable' do
    exp_time = 4200
    exp_coder = Opendax::Payload.new(secret: 'ab', expire: exp_time)
    encoded = exp_coder.generate!(service: service, image: image)
    decoded = exp_coder.decode!(encoded)
    computed_exp = decoded['exp'] - decoded['iat']

    expect(computed_exp).to eq exp_time
  end
end
