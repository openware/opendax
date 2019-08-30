namespace :parity do
  desc '[Optional] Import etherium blockchain data'
  task :import do
    destination = "#{Dir.pwd}/data/parity/rinkeby/parity"

    puts '----- Stoping parity service -----'
    sh 'docker-compose rm -fs parity'
    puts '----- Importing parity blockchain data -----'
    sh 'wget https://storage.googleapis.com/microkube-ethereum-node-chaindata-backups/ethdata_fullsync.tar.gz'
    sh "mkdir -p #{destination}"
    sh "tar -C #{destination} -zxvf ethdata_fullsync.tar.gz"
    sh 'rm -rf ethdata_fullsync.tar.gz'
    puts '----- Restarting parity service -----'
    sh 'docker-compose up -Vd parity'
  end

  task :export do
    puts '----- Exporting parity blockchain data -----'
    sh 'tar czf data/parity ethdata_fullsync.tar.gz'
  end
end
