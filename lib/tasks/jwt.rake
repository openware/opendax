
def generateKeys
    sh "openssl genrsa -out ./config/rsa.key 2048"
    sh "openssl rsa -in ./config/rsa.key -outform PEM -pubout -out ./config/rsa.key.pub"
end

namespace :jwt do
    desc "Generate keypairs for Barong, Peatio and Jest"

    task :generate do
        generateKeys
    end
end

