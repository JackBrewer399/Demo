#require 'sinatra'
require 'rubygems'
require 'ruby'
require 'pg'
require 'yaml'

# Enable session storing in cookies
use Rack::Session::Cookie, :key => 'rack.session',
                               :expire_after => 86400
# Disable Rack frame embedding protection
set :protection, :except => :frame_options


# Load database and evernote API info
conninfo = YAML.load_file('settings.yml')

# Connect to database
$dbconn = PG.connect(conninfo["db"]["host"],
                    conninfo["db"]["port"],
                    nil, # options
                    nil, # tty
                    conninfo["db"]["dbname"],
                    conninfo["db"]["user"],
                    conninfo["db"]["password"])

# Attempt creation of database
begin
  $dbconn.exec("CREATE TABLE QUIZ_TABLE ( APP_ID text NOT NULL, QUESTION text, ANSWER text, EXPIRES timestamp, PRIMARY KEY (APP_ID) );")
  db_addQuestion('1','In what year was the Oscar for best picture first awarded?\nA: 1929\t\tB: 1925\nC: 1930\t\tD: 1928', 'D')
rescue
  # Database already exists, or another error
end

##
# Add a question to the database
##
def db_addQuestion(pAppID, pQuestion, pAnswer, expires)
  $dbconn.query("INSERT INTO QUIZ_TABLE (APP_ID, QUESTION, ANSWER, expires) VALUES ('#{pAppID}', '#{pQuestion}', '#{pAnswer}', to_timestamp(#{expires}));")
end

##
# Get a question from the database
##
def db_getQuestion(lmsID)
  result = $dbconn.query("SELECT APP_ID, QUESTION, ANSWER, expires FROM QUIZ_TABLE WHERE APP_ID = '#{appID}'")
  
  if result.num_tuples.zero?
    # No results
    return nil
  else
    # Return a hash of the result
    return result[0]
  end
end

#def add_rows 
 #   db_addQuestion('1','In what year was the Oscar for best picture first awarded?\nA: 1929\t\tB: 1925\nC: 1930\t\tD: 1928', 'D')
    
#end
























