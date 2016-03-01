CERT_DIR = File.join(File.dirname(__FILE__), "../..", "certs")

Dor::Config.configure do

  fedora do
    url       'https://USERNAME:PASSWORD@example.com/fedora'
  end

  ssl do
    cert_file File.join(CERT_DIR, "dlss-dev-test.crt")
    key_file  File.join(CERT_DIR, "dlss-dev-test.key")
    key_pass  ''
  end

  workflow.url 'https://example.com/workflow/'
  solr.url 'http://localhost:8080/solr/argo'
  
  robots do 
    workspace '/tmp'
  end
  
  release do
    fetcher_root 'http://localhost:3000/'
    workflow_name 'releaseWF'
    max_tries  5  # the number of attempts to retry service calls before failing
    max_sleep_seconds   120  # max sleep seconds between tries
    base_sleep_seconds  10   # base sleep seconds between tries       
    purl_base_uri 'http://purl.stanford.edu/' 
    symphony_path './'
    write_marc_script 'bin/write_marc_record_test'
  end

  dor do
    service_root 'https://USERNAME:PASSWORD@example.com/dor/v1'
  end
   
end

REDIS_URL = '127.0.0.1:6379/resque:development' # hostname:port[:db]/namespace
# REDIS_TIMEOUT = '5' # seconds
