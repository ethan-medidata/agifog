# IAM REST SPECIFICATION

Base url: /api/v1/iam

## Users

Request mimics the aws API, model isn't implemented for IAM yet

    REQUEST  | MODEL    | AgiFog  |
    UserId   | user_id  | user_id |
    Path     | path     | path    |
    Arn      | arn      | arn     |
    UserName | id       | id      |


### - List Users
  
Returns an array of hashes in json format
    
    GET /users

example

    GET /users
    
    [
        {
            "user_id": "AIDAJS7AZM2FBVET4X3ES",
            "path": "/",
            "id": "atrull",
            "arn": "arn:aws:iam::076395046979:user/atrull"
        },
        {
            "user_id": "AIDAIYZIKMTWAMCIRWCPW",
            "path": "/",
            "id": "broberts",
            "arn": "arn:aws:iam::076395046979:user/broberts"
        }
    ]
    
fog request

    iam.list_users
    
fog model
    
    iam.users
    
    [
        <Fog::AWS::IAM::User
            id="atrull",
            user_id="AIDAJS7AZM2FBVET4X3ES",
            arn="arn:aws:iam::076395046979:user/atrull",
            path="/"
        >,
        <Fog::AWS::IAM::User
            id="broberts",
            user_id="AIDAIYZIKMTWAMCIRWCPW",
            arn="arn:aws:iam::076395046979:user/broberts",
            path="/"
        >
    ]
            
  
### - List a single user

    GET /users/:id
    
Returns a hash

example

    GET /users/atrull
        
    {
        "user_id": "AIDAJS7AZM2FBVET4X3ES",
        "path": "/",
        "id": "atrull",
        "arn": "arn:aws:iam::076395046979:user/atrull"
    }
    
fog request

    iam.get_user('UserName' => 'atrull')
    
fog model

    iam.users.get('atrull')

     <Fog::AWS::IAM::User
         id="atrull",
         user_id="AIDAJS7AZM2FBVET4X3ES",
         arn="arn:aws:iam::076395046979:user/atrull",
         path="/"
     >
    
### - Create a user

    POST /users
    
we pass a hash with the user key

example

    POST "/users", 
    
    {
        "user": {
            "id": "restebanez"
        }
    }
    
it returns

    {
        "user": {
            "user_id": "AIDAII265PTLWB6LTSIRS",
            "path": "/",
            "id": "restebanez",
            "arn": "arn:aws:iam::076395046979:user/restebanez"
        }
    }
    
fog request

    iam.create_user('restebanez')
    
fog model

    iam.users.create(:id => 'restebanez')
    
### - Delete a user

    DELETE /users/:id
    
example
    
    DELETE /users/restebanez
    
    [
        "restebanez was deleted successfully"
    ]

fog request

    iam.delete_user('restebanez')

fog model

    user = iam.users.get('restebanez')
    user.destroy

## User's policies

    REQUEST        | MODEL    | AgiFog   |
    UserName       | username | username |
    PolicyName     | id       | id     |
    PolicyDocument | document | document |


### - List user's policies

    GET /users/:id/policies
    
example

    GET /users/restebanez/policies
    
    [
        {
            "id": "policy_sqs",    
            "document" : "{"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}"

        },
        {
            "id": "policy_rds",
            "document" : "{"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}"
        }
    ]
    
fog request

    iam.list_user_policies('restebanez')
    
fog model
    
    iam.users.get('restebanez').policies

### - List a user policy

    GET /users/:id/policies/:id
    
The Policy name character restriction is 128 chars

example

    GET /users/restebanez/policies/policy_sqs
    
    {
        "id": "policy_sqs",
        "document" : "{"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}"
    }
    
fog request

    iam.get_user_policy('policy_sqs','restebanez')

fog model
    
    iam.users.get('restebanez').policies.get('policy_sqs')

### - Create a user policy

    POST /users/:id/policies
    
example

    POST /users/restebanez/policies, 
    
    {
        "policy": {
            "id": "new-policy",
            "document": '{"Statement"=>[{"Action"=>["sqs:*"], "Effect"=>"Allow", "Resource"=>"*"}]}'
        }
    }
    
fog request

    p_document = {"Statement"=>[{"Action"=>["sqs:*"], "Effect"=>"Allow", "Resource"=>"*"}]}
    iam.put_user_policy('restebanez','new-policy',p_document)
	
    
fog model

    opts = {
        :document => "{"Statement"=>[{"Action"=>["sqs:*"], "Effect"=>"Allow", "Resource"=>"*"}]}",
        :id => 'new-policy'
    }
    iam.users.get('restebanez').policies.create(opts)


### - Delete a user policy

    DELETE /users/:id/policies/:id
    
example

    DELETE /users/restebanez/policies/new-policy
    
    [
        "new-policy was deleted successfully"
    ]
    
fog request

    iam.delete_user_policy('restebanez','new-policy')
    
fog model

    iam.users.get('restebanez').policies.get('new-policy').destory
    
## User's access_keys

    REQUEST         | MODEL             | AgiFog            |
    UserName        | username          | username          |
    AccessKeyId     | id                | id                |
    SecretAccessKey | secret_access_key | secret_access_key |
    Status          | status            | status            |

    
    
### - List user's access_keys

    GET /users/restebanez/access_keys
    
    [
        {
            "id" : "AKIAJBC4FC2SUFN3U32A",
            "status" : "Active"
        },
        {
            "id" : "XXXDFDFDFDFDFDFDFDFD",
            "status" : "Active"
        }
    ]

fog request 

    iam.list_access_keys('UserName'=> 'restebanez')
    
fog model

    iam.users.get('restebanez').access_keys
    
    
### - List a user access_key

    GET /users/:id/access_keys/:id
    
example

    GET /users/restebanez/access_keys/AKIAJBC4FC2SUFN3U32A

    {
        "id" : "AKIAJBC4FC2SUFN3U32A",
        "status" : "Active"
    }
    
fog model and request

There is no get_access_key method in fog request. Although maybe i should implement:

    iam.users.get('restebanez').access_keys.get('XXXDFDFDFDFDFDFDFDFD')

### - Create a user access_key

    POST /users/:id/access_keys

example

Nothing has to be pass to /users/rodrigo/access_keys

    POST /users/restebanez/access_keys
    
it returns

    {
        "access_key": {
            "id": "AKIAJBC4FC2SUFN3U32A",
            "secret_access_key" :"blablabal"
        }
    }

fog request

    iam.create_access_key('UserName'=>'restebanez')
    
fog model
    
    iam.users.get('restebanez').access_keys.create()

### - Delete a user access_key

    DELETE /users/restebanez/access_keys/:id

example

    DELETE /users/restebanez/access_keys/AKIAJBC4FC2SUFN3U32A

    [
        "AKIAJBC4FC2SUFN3U32A was deleted successfully"
    ]

fog model

    iam.users.get('restebanez').access_keys.get('AKIAJBC4FC2SUFN3U32A').destroy

fog request

    iam.delete_access_key('AKIAJBC4FC2SUFN3U32A','UserName'=>'rodrigo')
