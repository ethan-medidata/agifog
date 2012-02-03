module AgiFog
API=
    {
                       "id" => "agi_fog:v1",
                     "name" => "agi_fog",
                  "version" => "v1",
                    "title" => "agi fog",
              "description" => "Service to talk to aws",
        "documentationLink" => "https://github.com/restebanez/agifog",
                 "protocol" => "rest",
                 "basePath" => "/api/v1/",
                "resources" => {
                    "rds_servers" => {
                "methods" => {
                      "list" => {
                                 "id" => "agifog.rds_server.list",
                               "path" => "rds/servers",
                         "httpMethod" => "GET",
                        "description" => "Gets every rds server",
                         "parameters" => {}
                    },
                      "show" => {
                                 "id" => "agifog.rds_server.show",
                               "path" => "rds/servers/{id}",
                         "httpMethod" => "GET",
                        "description" => "Gets a rds server",
                         "parameters" => {
                            "id" => {
                                       "type" => "string",
                                "description" => "rds server id",
                                   "required" => true,
                                   "location" => "path"
                            }
                        }
                    },
                    "create" => {
                                 "id" => "agifog.rds_server.create",
                               "path" => "rds/servers",
                         "httpMethod" => "POST",
                        "description" => "Create a new rds server",
                         "parameters" => {}
                    }
                }
            },
            "rds_security_groups" => {
                "methods" => {
                    "list" => {
                                 "id" => "agifog.rds_security_groups.list",
                               "path" => "rds/security_groups",
                         "httpMethod" => "GET",
                        "description" => "Gets every rds security group",
                         "parameters" => {}
                    },
                    "show" => {
                                 "id" => "agifog.rds_security_groups.show",
                               "path" => "rds/security_groups/{id}",
                         "httpMethod" => "GET",
                        "description" => "Gets a security group server",
                         "parameters" => {
                            "id" => {
                                       "type" => "string",
                                "description" => "rds security group id",
                                   "required" => true,
                                   "location" => "path"
                            }
                        }
                    },
                    "authorize" => {
                                 "id" => "agifog.rds_security_groups.authorize",
                               "path" => "rds/security_groups/{id}/authorize",
                         "httpMethod" => "PUT",
                        "description" => "Authorize a security group server",
                         "parameters" => {
                            "id" => {
                                       "type" => "string",
                                "description" => "rds authorize a security group id",
                                   "required" => true,
                                   "location" => "path"
                            }
                        }
                    }
                }
            }
        }
    }


end