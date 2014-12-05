CERT_DIR = File.join(File.dirname(__FILE__), "..", "certs")

Dor::Config.configure do

  fedora do
    url       'https://USERNAME:PASSWORD@example.com/fedora'
  end

  ssl do
    cert_file File.join(CERT_DIR, "dlss-dev-test.crt")
    key_file  File.join(CERT_DIR, "dlss-dev-test.key")
    key_pass  ''
  end
  
  robots do 
    workspace '/tmp'
  end
  
  itemRelease do
    fetcher_root 'https://dor-fetcher-service/'
    workflow_name 'releaseWF'
  end

  dor do
    service_root 'https://USERNAME:PASSWORD@example.com/dor/v1'
  end
   
end

REDIS_URL = '127.0.0.1:6379/resque:development' # hostname:port[:db]/namespace
# REDIS_TIMEOUT = '5' # seconds
