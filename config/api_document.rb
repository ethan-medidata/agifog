module AgiFog
  API = {
    'id' => "agi_fog:v1",
    'name' => 'agi_fog',
    'version' => "v1",
    'title' => 'agi fog',
    'description' => "Service to talk to aws",
    'documentationLink' => "https://github.com/restebanez/agifog",
    'protocol' => 'rest',
    'basePath' => '/api/v1/',
    'resources' => {
      'rds_servers' => {
        'methods' => {
          'list' => {
            'id' => 'agifog.rds_server.list',
            'path' => 'rds/servers',
            'httpMethod' => 'GET',
            'description' => "Gets every rds server",
            'parameters' => { },
          },
        },
      },
     
    },
  }
end